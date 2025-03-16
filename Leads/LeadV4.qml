import QtQuick
import QtQuick.Controls
import QtGraphs

Item {
    width: 1000
    height: 600

    // ✅ Directly assign the preloaded C++ data
    property var leadData: ekgLead10

    GraphsView {
        id: ekgGraph
        width: parent.width
        height: parent.height

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
            max: leadData ? leadData.length : 4096  // ✅ Automatically set max X-axis value
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

            // ✅ Directly replace entire dataset without a loop
            Component.onCompleted: {
                if (leadData && leadData.length > 0) {
                    ekgSeries.replace(leadData.map((value, index) => Qt.point(index, value)));
                } else {
                    console.warn("❌ No data available for Lead 1");
                }
            }
        }
    }
}
