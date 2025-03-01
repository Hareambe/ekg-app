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

        // Dropdown to select the EKG lead
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
                seriesColors: ["red"] // ✅ Red lines for the EKG
                borderColors: ["gray"]
                grid.mainColor: "#606060" // ✅ White-ish grid for visibility
                grid.subColor: "#404040"
                axisX.mainColor: "white"
                axisY.mainColor: "white"
            }

            axisX: ValueAxis {
                id: xAxis
                min: 0
                max: (typeof ekgLead1 !== "undefined" && ekgLead1.length > 0)
                        ? ekgLead1.length - 1 : 1000
            }

            axisY: ValueAxis {
                id: yAxis
                min: -1000
                max: 3500
            }

            LineSeries {
                id: ekgSeries
                width: 2
                capStyle: Qt.RoundCap
                color: "red" // ✅ Ensures EKG lines are RED
            }
        }
    }

    // Function to update the graph when a lead is selected
    function updateGraph() {
        ekgSeries.clear();
        let leadIndex = leadSelector.currentIndex;
        let data = eval("ekgLead" + (leadIndex + 1));
        let minVal = ekgLeadMin[leadIndex];
        let maxVal = ekgLeadMax[leadIndex];

        yAxis.min = minVal - 100;  // ✅ Adds buffer to min for better visualization
        yAxis.max = maxVal + 100;  // ✅ Adds buffer to max for better visualization

        if (typeof data !== "undefined" && data.length > 0) {
            for (var i = 0; i < data.length; i++) {
                ekgSeries.append(i, data[i]);
            }
            console.log("Plotted", data.length, "points for Lead", leadIndex + 1);
        } else {
            console.warn("No data available for Lead", leadIndex + 1);
        }
    }

    // Automatically plot Lead 1 on startup
    Component.onCompleted: updateGraph();
}
