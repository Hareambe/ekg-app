import QtQuick
import QtQuick.Controls
import QtGraphs

ApplicationWindow {
    visible: true
    width: 1000
    height: 700
    title: "EKG Data Visualization"

    Column {
        anchors.fill: parent
        spacing: 10

        // ✅ Dropdown to select the EKG lead
        ComboBox {
            id: leadSelector
            width: 200
            model: ["Lead 1", "Lead 2", "Lead 3", "Lead 4", "Lead 5", "Lead 6",
                    "Lead 7", "Lead 8", "Lead 9", "Lead 10", "Lead 11", "Lead 12"]
            onCurrentIndexChanged: updateGraph()
        }

        GraphsView {
            id: ekgGraph
            width: parent.width
            height: parent.height * 0.85

            theme: GraphsTheme {
                colorScheme: GraphsTheme.ColorScheme.Dark
                seriesColors: ["red"]
                borderColors: ["gray"]
                grid.mainColor: "#606060"
                grid.subColor: "#404040"
                axisX.mainColor: "white"
                axisY.mainColor: "white"
            }

            axisX: ValueAxis {
                id: xAxis
                min: 0
                max: 4096  // ✅ Assuming 4096 samples per lead
            }

            axisY: ValueAxis {
                id: yAxis
                min: -3
                max: 3
            }

            LineSeries {
                id: ekgSeries
                width: 2
                capStyle: Qt.RoundCap
                color: "red"
            }
        }
    }

    // ✅ Preload all leads into an array at startup
    property var ekgLeadsArray: []

    Component.onCompleted: {
        console.log("✅ Preloading all 12 leads...");
        ekgLeadsArray = [ekgLead1, ekgLead2, ekgLead3, ekgLead4, ekgLead5, ekgLead6,
                         ekgLead7, ekgLead8, ekgLead9, ekgLead10, ekgLead11, ekgLead12];

        // ✅ Verify that data is correctly received
        for (let i = 0; i < 12; i++) {
            if (typeof ekgLeadsArray[i] !== "undefined" && ekgLeadsArray[i].length > 0) {
                console.log("✅ Lead", i + 1, "First 5 values:", ekgLeadsArray[i].slice(0, 5));
            } else {
                console.warn("❌ No data for Lead", i + 1);
            }
        }

        // ✅ Automatically load Lead 1
        updateGraph();
    }

    // ✅ Switch between preloaded leads instead of reloading
    function updateGraph() {
        let leadIndex = leadSelector.currentIndex;
        let data = ekgLeadsArray[leadIndex];

        if (typeof data !== "undefined" && data.length > 0) {
            let points = [];
            for (let i = 0; i < data.length; i++) {
                points.push(Qt.point(i, data[i]));  // ✅ Convert raw values to Qt points
            }
            ekgSeries.replace(points);

            // ✅ Adjust Y-Axis dynamically
            yAxis.min = ekgLeadMin[leadIndex] - 0.5;
            yAxis.max = ekgLeadMax[leadIndex] + 0.5;
            console.log("✅ Switched to Lead", leadIndex + 1);
        } else {
            console.warn("❌ No data available for Lead", leadIndex + 1);
        }
    }
}
