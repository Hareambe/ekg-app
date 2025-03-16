import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    visible: true
    width: 1000
    height: 700
    title: "EKG Data Visualization"

    Column {
        anchors.fill: parent
        spacing: 10

        // ✅ Dropdown to select either one lead or all leads
        ComboBox {
            id: leadSelector
            width: 200
            model: ["Lead I", "Lead II", "Lead III", "Lead aVR", "Lead aVL", "Lead aVF", "Lead V1", "Lead V2", "Lead V3", "Lead V4", "Lead V5", "Lead V6"]
            onCurrentIndexChanged: loader.source = getLeadFile(currentIndex)
        }

        // ✅ Loader to dynamically load either all leads or a single lead
        Loader {
            id: loader
            width: parent.width
            height: parent.height * 0.85
            source: "Leads/LeadI.qml" // ✅ Default to "All" view
        }
    }

    // ✅ Function to get the correct QML file
    function getLeadFile(index) {
        const leadFiles = ["Leads/LeadI.qml", "Leads/LeadII.qml", "Leads/LeadIII.qml", "Leads/LeadAVR.qml", "Leads/LeadAVL.qml", "Leads/LeadAVF.qml", "Leads/LeadV1.qml", "Leads/LeadV2.qml", "Leads/LeadV3.qml", "Leads/LeadV4.qml", "Leads/LeadV5.qml", "Leads/LeadV6.qml"]
        return leadFiles[index]
    }
}
