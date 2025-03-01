cmake_minimum_required(VERSION 3.16)

project(ekg-app VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2 Graphs)
qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(appekg-app
    main.cpp
    src/handlers/hdf5_handler.cpp
    src/handlers/hdf5_handler.h
    src/handlers/datasetmodel.cpp
    src/handlers/datasetmodel.h
)

set(HDF5_HEADER_PATH "${CMAKE_SOURCE_DIR}/headers/hdf5")  # Path to HDF5 headers
set(HIGHFIVE_HEADER_PATH "${CMAKE_SOURCE_DIR}/headers/highfive")  # Path to HDF5 headers
set(HDF5_LIB_PATH "${CMAKE_SOURCE_DIR}/android/libs/x86_64") # Path to HDF5 shared libraries

include_directories(${HDF5_HEADER_PATH} ${HIGHFIVE_HEADER_PATH})
qt_add_qml_module(appekg-app
    URI ekg-app
    VERSION 1.0
    QML_FILES
        Main.qml
)
target_link_libraries(appekg-app PRIVATE
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Graphs
    ${HDF5_LIB_PATH}/libhdf5.so
    ${HDF5_LIB_PATH}/libhdf5_hl.so
)
if(ANDROID)
    # Install the HDF5 shared libraries to the libs/x86_64 directory within the APK
    install(FILES
        "${HDF5_LIB_PATH}/libhdf5.so"
        "${HDF5_LIB_PATH}/libhdf5_hl.so"
        DESTINATION libs/x86_64
    )

    # Specify additional Android properties
    set_target_properties(appekg-app
        PROPERTIES
           QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_SOURCE_DIR}/android"
            QT_ANDROID_TARGET_SDK_VERSION "33"

    )

    # Ensure that the HDF5 shared libraries are copied to the APK build directory after building
    add_custom_command(TARGET appekg-app POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory
            "$<TARGET_FILE_DIR:appekg-app>/libs/x86_64"
    )
    add_custom_command(TARGET appekg-app POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${HDF5_LIB_PATH}/libhdf5.so"
            "$<TARGET_FILE_DIR:appekg-app>/libs/x86_64/libhdf5.so"
    )
    add_custom_command(TARGET appekg-app POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${HDF5_LIB_PATH}/libhdf5_hl.so"
            "$<TARGET_FILE_DIR:appekg-app>/libs/x86_64/libhdf5_hl.so"
    )
endif()
# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appekg-app PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appekg-app
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)


include(GNUInstallDirs)
install(TARGETS appekg-app
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
