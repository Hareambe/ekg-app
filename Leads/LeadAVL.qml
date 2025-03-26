import QtQuick
import QtQuick.Controls
import QtGraphs

Item {
    width: 1000
    height: 600

    Flickable {
        id: flick
        width: parent.width
        height: parent.height
        contentWidth: ekgGraph.width * ekgGraph.scale
        contentHeight: ekgGraph.height * ekgGraph.scale
        clip: true
        interactive: ekgGraph.scale > 1.0 // Enable panning only when zoomed

        ScrollBar.vertical: ScrollBar {
            active: flick.contentHeight > flick.height
        }
        ScrollBar.horizontal: ScrollBar {
            active: flick.contentWidth > flick.width
        }

        PinchArea {
            id: pinch
            anchors.fill: parent
            property real initialScale: 1.0
            property real minScale: 1.0
            property real maxScale: 5.0

            onPinchStarted: {
                initialScale = ekgGraph.scale
            }

            onPinchUpdated: {
                var newScale = initialScale * pinch.scale
                newScale = Math.max(minScale,
                                    Math.min(maxScale,
                                             newScale)) // Clamping zoom

                var scaleRatio = newScale / ekgGraph.scale
                ekgGraph.scale = newScale

                // Adjust flickable content position to keep zoom centered
                flick.contentX -= (pinch.center.x - flick.width / 2) * (scaleRatio - 1)
                flick.contentY -= (pinch.center.y - flick.height / 2) * (scaleRatio - 1)
                flick.contentWidth = ekgGraph.width * ekgGraph.scale
                flick.contentHeight = ekgGraph.height * ekgGraph.scale
            }
        }

        GraphsView {
            id: ekgGraph
            width: flick.width
            height: flick.height
            scale: 1.0
            anchors.centerIn: parent

            theme: GraphsTheme {
                colorScheme: GraphsTheme.ColorScheme.Light
                backgroundVisible: true
                backgroundColor: "#FFF0F0"
                grid.mainColor: "#EEAAAA"
                grid.subColor: "#FFDADA"
                borderColors: ["transparent"]
                seriesColors: ["#000000"]
            }

            axisX: ValueAxis {
                id: xAxis
                min: 0
                max: 4095
                labelsVisible: false
                lineVisible: false
                tickInterval: 80
                subTickCount: 4
                labelDecimals: 1
            }

            axisY: ValueAxis {
                id: yAxis
                min: -4
                max: 4
                labelsVisible: false
                lineVisible: false
                tickInterval: 0.5
                subTickCount: 4
                labelDecimals: 1
            }

            LineSeries {
                id: ekgSeries
                width: 2
                capStyle: Qt.RoundCap
                color: "#000000"

                Component.onCompleted: {
                    ekgSeries.replace(ekgLead5.map((val, i) => Qt.point(i,
                                                                        val)))
                }
            }
        }
        Text {
            text: "aVL"
            color: "#000000"
            font.pixelSize: 50
            anchors.left: ekgGraph.left
            anchors.bottom: ekgGraph.bottom
            anchors.leftMargin: 100
            anchors.bottomMargin: 80
            z: 999 // ensure it's drawn on top
        }
    }
}
