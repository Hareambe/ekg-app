cmake_minimum_required(VERSION 3.16)

project(ekg-app VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2 Graphs SerialPort Sql Network)
qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(appekg-app
    main.cpp
    ecgserial.h
    ecgserial.cpp
)

#set(HDF5_HEADER_PATH "${CMAKE_SOURCE_DIR}/headers/hdf5")         # Path to HDF5 headers
#set(HIGHFIVE_HEADER_PATH "${CMAKE_SOURCE_DIR}/headers/highfive")   # Path to HighFive headers

#include_directories(${HDF5_HEADER_PATH} ${HIGHFIVE_HEADER_PATH})

qt_add_qml_module(appekg-app
    URI ekg-app
    VERSION 1.0
    QML_FILES
        Main.qml
        Leads/LeadI.qml
        Leads/LeadII.qml
        Leads/LeadIII.qml
        Leads/LeadAVR.qml
        Leads/LeadAVL.qml
        Leads/LeadAVF.qml
        Leads/LeadV1.qml
        Leads/LeadV2.qml
        Leads/LeadV3.qml
        Leads/LeadV4.qml
        Leads/LeadV5.qml
        Leads/LeadV6.qml
        Leads/AllLeads.qml
        EKGViewer.qml
        QML_FILES ECGEmulator.qml
    SOURCES
        ecgsql.h
        ecgsql.cpp
        logger.cpp
        logger.h
        ecgemulate.h
        ecgemulate.cpp
        SOURCES env.h env.cpp
)

# Set default library path for OpenSSL for non-Android targets (assume x86_64)
set(OPENSSL_LIB_PATH "${CMAKE_SOURCE_DIR}/android/libs/x86_64")
set(ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android")

# For Android, choose OpenSSL library paths based on the target ABI
if(ANDROID)
    if(${ANDROID_ABI} STREQUAL "arm64-v8a")
        set(OPENSSL_LIB_PATH "${CMAKE_SOURCE_DIR}/android/libs/arm64-v8a")
    else()
        set(OPENSSL_LIB_PATH "${CMAKE_SOURCE_DIR}/android/libs/x86_64")
    endif()
endif()

target_link_libraries(appekg-app PRIVATE
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Graphs
    Qt6::SerialPort
    Qt6::Sql
    Qt6::Network
    $<$<PLATFORM_ID:Android>:${OPENSSL_LIB_PATH}/libssl_3.so>
    $<$<PLATFORM_ID:Android>:${OPENSSL_LIB_PATH}/libcrypto_3.so>
    $<$<NOT:$<PLATFORM_ID:Android>>:${OPENSSL_LIB_PATH}/libssl_3.so>
    $<$<NOT:$<PLATFORM_ID:Android>>:${OPENSSL_LIB_PATH}/libcrypto_3.so>
)

qt_add_resources(appekg-app "resources"
    PREFIX "/"
    FILES resources/.env
)

if(ANDROID)
    install(FILES
         "resources/.env"
         DESTINATION assets/
    )
    install(FILES
        "${OPENSSL_LIB_PATH}/libssl_3.so"
        "${OPENSSL_LIB_PATH}/libcrypto_3.so"
        DESTINATION libs/${ANDROID_ABI}
    )

    set_target_properties(appekg-app
        PROPERTIES
            QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_SOURCE_DIR}/android"
            QT_ANDROID_TARGET_SDK_VERSION "33"
    )

    add_custom_command(TARGET appekg-app POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory "$<TARGET_FILE_DIR:appekg-app>/libs/${ANDROID_ABI}"
    )
    add_custom_command(TARGET appekg-app POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${OPENSSL_LIB_PATH}/libssl_3.so"
            "$<TARGET_FILE_DIR:appekg-app>/libs/${ANDROID_ABI}/libssl_3.so"
    )
    add_custom_command(TARGET appekg-app POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${OPENSSL_LIB_PATH}/libcrypto_3.so"
            "$<TARGET_FILE_DIR:appekg-app>/libs/${ANDROID_ABI}/libcrypto_3.so"
    )
endif()

set_target_properties(appekg-app PROPERTIES
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
