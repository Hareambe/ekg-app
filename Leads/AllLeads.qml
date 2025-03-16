import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    width: 1000
    height: 600

    GridLayout {
        anchors.fill: parent
        columns: 3
        rowSpacing: 5
        columnSpacing: 5

        // ✅ Load all 12 leads in a grid format
        LeadI { Layout.fillWidth: true; Layout.fillHeight: true }
        LeadII { Layout.fillWidth: true; Layout.fillHeight: true }
        LeadIII { Layout.fillWidth: true; Layout.fillHeight: true }
        LeadAVR { Layout.fillWidth: true; Layout.fillHeight: true }
        LeadAVL { Layout.fillWidth: true; Layout.fillHeight: true }
        LeadAVF { Layout.fillWidth: true; Layout.fillHeight: true }
        LeadV1 { Layout.fillWidth: true; Layout.fillHeight: true }
        LeadV2 { Layout.fillWidth: true; Layout.fillHeight: true }
        LeadV3 { Layout.fillWidth: true; Layout.fillHeight: true }
        LeadV4 { Layout.fillWidth: true; Layout.fillHeight: true }
        LeadV5 { Layout.fillWidth: true; Layout.fillHeight: true }
        LeadV6 { Layout.fillWidth: true; Layout.fillHeight: true }
    }
}
