import QtQuick
import QtQuick.Controls

// ✅ Fix for nested components


/* ApplicationWindow {
    visible: true
    width: 1000
    height: 700
    title: "EKG Data Visualization"

    StackView {
        id: viewStack
        anchors.fill: parent
        initialItem: startScreen // ✅ Show buttons first
    }

    Component {
        id: startScreen
        Item {
            anchors.fill: parent

            Column {
                anchors.centerIn: parent // ✅ Centers buttons
                spacing: 20

                Button {
                    text: "Read ECG Data"
                    width: 200
                    height: 50
                    onClicked: {
                        console.log("Button clicked, calling readECGData()")
                        ecgLoader.readECGData()
                    }
                }

                Button {
                    text: "Get Data from DB"
                    width: 200
                    height: 50
                    enabled: false // To be implemented later
                }
            }
        }
    }

    // ✅ Ensure ECG data is fully loaded before switching screens
    Connections {
        target: ecgLoader
        function onEcgDataLoaded() {
            console.log("ECG Data Loaded Signal Received. Switching to Viewer...")
            viewStack.push(ecgViewer)
        }
    }

    Component {
        id: ecgViewer
        EKGViewer {}
    }
}
*/
ApplicationWindow {
    visible: true
    width: 1000
    height: 700
    title: "EKG Data Management"

    // Main UI navigation via StackView
    StackView {
        id: viewStack
        anchors.fill: parent
        initialItem: mainMenu
    }

    // The Main Menu screen
    Component {
        id: mainMenu
        Item {
            anchors.fill: parent

            Column {
                anchors.centerIn: parent
                spacing: 20

                Button {
                    text: "Generate Fake ECG Data"
                    width: 250
                    height: 50
                    onClicked: {
                        console.log("Generating ECG Data...")
                        ecgSerial.generateFakeECGData()
                    }
                }

                Button {
                    text: "View Data"
                    width: 250
                    height: 50
                    onClicked: {
                        console.log("Switching to ECG Viewer...")
                        viewStack.push(ecgViewerComponent.createObject(
                                           viewStack, {
                                               "stackView": viewStack
                                           }))
                    }
                }

                Button {
                    text: "Upload Data to DB"
                    width: 250
                    height: 50
                    onClicked: {
                        console.log("Uploading ECG Data to Supabase...")
                        ecgSql.saveECGData(ekgLead1, ekgLead2, ekgLead3,
                                           ekgLead4, ekgLead5, ekgLead6,
                                           ekgLead7, ekgLead8, ekgLead9,
                                           ekgLead10, ekgLead11, ekgLead12)
                    }
                }

                Button {
                    text: "Get Latest Data from DB"
                    width: 250
                    height: 50
                    onClicked: {
                        console.log("Fetching latest ECG Data...")
                        ecgSql.loadLatestECGData()
                    }
                }

                Button {
                    text: "Test ECG Emulation"
                    width: 250
                    height: 50
                    onClicked: {
                        console.log("Switching to ECG Emulator view...")
                        viewStack.push(ecgEmulatorComponent.createObject(
                                           viewStack, {
                                               "stackView": viewStack
                                           }))
                    }
                }
            }
        }
    }

    // EKGViewer screen component
    Component {
        id: ecgViewerComponent
        EKGViewer {
            stackView: viewStack
        }
    }

    // ECGEmulator screen component
    Component {
        id: ecgEmulatorComponent
        ECGEmulator {
            stackView: viewStack
        }
    }
}
