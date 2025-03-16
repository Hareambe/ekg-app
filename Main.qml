import QtQuick
import QtQuick.Controls
import QtQuick.Layouts


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
                    text: "Generate Fake ECG Data"
                    width: 250
                    height: 50
                    onClicked: {
                        console.log("Button clicked, generating fake ECG data")
                        ecgSerial.generateFakeECGData()
                    }
                }

                Button {
                    text: "Get Data from DB"
                    width: 250
                    height: 50
                    enabled: false // To be implemented later
                }
            }
        }
    }

    // ✅ Ensure ECG data is fully loaded before switching screens
    Connections {
        target: ecgSerial
        function onEcgDataUpdated() {
            console.log("ECG Data Generated. Switching to Viewer...")
            viewStack.push(ecgViewer)
        }
    }

    Component {
        id: ecgViewer
        EKGViewer {}
    }
}
