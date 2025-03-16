import QtQuick
import QtQuick.Controls
import QtGraphs

Item {
    width: 800
    height: 200  // Adjust as needed for the grid layout

    // ✅ Lead label in the top-left corner
    Text {
        text: "I"
        color: "red"
        font.pixelSize: 20
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 5
    }

    GraphsView {
        id: ekgGraph
        width: parent.width
        height: parent.height

        theme: GraphsTheme {
            colorScheme: GraphsTheme.ColorScheme.Dark
            seriesColors: ["red"]
            borderColors: ["transparent"]  // ✅ Remove borders

        }

        axisX: ValueAxis {
            id: xAxis
            min: 0
            max: 4096
            labelsVisible: false  // ✅ Remove X-axis labels
            lineVisible: false  // ✅ Hide axis line
        }

        axisY: ValueAxis {
            id: yAxis
            min: -3
            max: 3
            labelsVisible: false  // ✅ Remove Y-axis labels
            lineVisible: false  // ✅ Hide axis line
        }

        LineSeries {
            id: ekgSeries
            width: 2
            capStyle: Qt.RoundCap
            color: "red"

            Component.onCompleted: {
                if (ekgLead1 && ekgLead1.length > 0) {
                    ekgSeries.replace(ekgLead1.map((value, index) => Qt.point(index, value)));
                } else {
                    console.warn("❌ No data available for Lead 1");
                }
            }
        }
    }
}
