import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
pragma ComponentBehavior

Item {
    id: root
    property StackView stackView

    width: parent.width
    height: parent.height

    Column {
        anchors.fill: parent
        spacing: 10

        Row {
            spacing: 20
            anchors.horizontalCenter: parent.horizontalCenter

            Button {
                text: "Back to Main Menu"
                width: 200
                height: 50
                onClicked: {
                    console.log("Returning to Main Menu...")
                    if (root.stackView) {
                        root.stackView.pop()
                    }
                }
            }

            ComboBox {
                id: leadSelector
                width: 200
                model: ["All Leads", "Lead I", "Lead II", "Lead III", "Lead aVR", "Lead aVL", "Lead aVF", "Lead V1", "Lead V2", "Lead V3", "Lead V4", "Lead V5", "Lead V6"]
                onCurrentIndexChanged: loader.source = getLeadFile(currentIndex)
            }
        }

        Loader {
            id: loader
            width: parent.width
            height: parent.height * 0.85
            source: "Leads/AllLeads.qml"
        }
    }

    function getLeadFile(index) {
        const leadFiles = ["Leads/AllLeads.qml", "Leads/LeadI.qml", "Leads/LeadII.qml", "Leads/LeadIII.qml", "Leads/LeadAVR.qml", "Leads/LeadAVL.qml", "Leads/LeadAVF.qml", "Leads/LeadV1.qml", "Leads/LeadV2.qml", "Leads/LeadV3.qml", "Leads/LeadV4.qml", "Leads/LeadV5.qml", "Leads/LeadV6.qml"]
        return leadFiles[index]
    }
}
