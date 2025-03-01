import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphs

ApplicationWindow {
    visible: true
    width: 800
    height: 600
    title: "EKG Data Visualization with GraphsView"

    GraphsView {
        anchors.fill: parent

        // X-Axis: using the data length if available
        axisX: ValueAxis {
            id: xAxis
            min: 0
            max: (typeof ekgGraphData !== "undefined" && ekgGraphData.length > 0)
                    ? ekgGraphData.length - 1 : 1000
        }

        // Y-Axis: fixed range for your EKG data
        axisY: ValueAxis {
            id: yAxis
            min: -1000
            max: 3500
        }

        LineSeries {
            id: ekgSeries
            color: "#00ff00"
            width: 2
            capStyle: Qt.RoundCap

            Component.onCompleted: {
                // Clear any pre-existing points and append your data
                clear();
                if (typeof ekgGraphData !== "undefined" && ekgGraphData.length > 0) {
                    for (var i = 0; i < ekgGraphData.length; i++) {
                        append(i, ekgGraphData[i]);
                    }
                    console.log("Plotted", ekgGraphData.length, "data points.");
                } else {
                    console.warn("No EKG data available.");
                }
            }
        }
    }
}
