import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    property StackView stackView
    width: parent.width
    height: parent.height

    ColumnLayout {
        anchors.fill: parent
        spacing: 20

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 20

            Button {
                text: "Back to Main Menu"
                onClicked: {
                    if (root.stackView)
                        root.stackView.pop()
                }
            }
        }

        TextField {
            id: portNameField
            Layout.preferredWidth: 300
            placeholderText: "Serial Port (e.g., /dev/ttyUSB0)"
            text: "/dev/ttyUSB0"
        }

        TextField {
            id: baudRateField
            Layout.preferredWidth: 300
            placeholderText: "Baud Rate (e.g., 9600)"
            text: "9600"
            inputMethodHints: Qt.ImhDigitsOnly
        }

        TextField {
            id: samplingRateField
            Layout.preferredWidth: 300
            placeholderText: "Sampling Rate (Hz, e.g., 250)"
            text: "250"
            inputMethodHints: Qt.ImhDigitsOnly
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 20

            Button {
                text: "Start Emulation"
                onClicked: {
                    // Set the sampling rate and start the emulation
                    ecgEmulate.setSamplingRate(parseFloat(
                                                   samplingRateField.text))
                    ecgEmulate.startEmulation(portNameField.text,
                                              parseInt(baudRateField.text))
                }
            }

            Button {
                text: "Stop Emulation"
                onClicked: {
                    ecgEmulate.stopEmulation()
                }
            }
        }
    }
}
