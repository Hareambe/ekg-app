

/*import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphs

Item {
    width: 1000
    height: 600

    GraphsView {
        id: ekgGraph
        anchors.fill: parent
        anchors.margins: 0

        theme: GraphsTheme {
            readonly property color c1: "#000000"
            readonly property color c2: "#F5DDEA"
            readonly property color c3: Qt.lighter(c2, 1.5)
            colorScheme: GraphsTheme.ColorScheme.Light
            seriesColors: ["#2CDE85", "#DBEB00"]
            grid.mainColor: "#ebb7cd"
            grid.subColor: c2
            axisX.mainColor: "#ebb7cd"
            axisY.mainColor: "#ebb7cd"
            axisX.subColor: c2
            axisY.subColor: c2
            axisX.labelTextColor: c1
            axisY.labelTextColor: c1
        }

        axisX: ValueAxis {
            id: xAxis
            min: 0
            max: 16533
            labelsVisible: false
            lineVisible: false
            tickInterval: 80
            subTickCount: 4
            labelDecimals: 1
        }

        axisY: ValueAxis {
            id: yAxis
            min: -11
            max: 11
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
                // Replace with your actual ECG data array for group 1 (ekgLine1)
                ekgSeries.replace(ekgLine1.map((val, i) => Qt.point(i, val)))
            }
        }
        LineSeries {
            id: ekgSeries2
            width: 2
            capStyle: Qt.RoundCap
            color: "#000000"

            Component.onCompleted: {
                // Replace with your actual ECG data array for group 2 (ekgLine2)
                ekgSeries2.replace(ekgLine2.map((val, i) => Qt.point(i, val)))
            }
        }
        LineSeries {
            id: ekgSeries3
            width: 2
            capStyle: Qt.RoundCap
            color: "#000000"

            Component.onCompleted: {
                // Replace with your actual ECG data array for group 3 (ekgLine3)
                ekgSeries3.replace(ekgLine3.map((val, i) => Qt.point(i, val)))
            }
        }
    }

    // Optional label for "I" positioned at the bottom left of the graph
    Text {
        text: "I"
        color: "#000000"
        font.pixelSize: 20
        anchors.left: ekgGraph.left
        anchors.top: ekgGraph.top
        anchors.leftMargin: 100
        anchors.bottomMargin: 80
        z: 999
    }
}
*/
import QtQuick
import QtQuick.Controls
import QtGraphs

Item {
    width: 2000
    height: 900

    Flickable {
        id: flick
        width: parent.width
        height: parent.height
        contentWidth: ekgGraph.width * ekgGraph.scale
        contentHeight: ekgGraph.height * ekgGraph.scale
        clip: true
        interactive: ekgGraph.scale > 0.4 // Enable panning only when zoomed

        ScrollBar.vertical: ScrollBar {
            active: flick.contentHeight > flick.height
        }
        ScrollBar.horizontal: ScrollBar {
            active: flick.contentWidth > flick.width
        }

        PinchArea {
            id: pinch
            anchors.fill: parent
            property real initialScale: 0.4
            property real minScale: 0.4
            property real maxScale: 3.5

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
            width: 2000
            height: 900
            scale: 0.4
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
                max: 16533
                labelsVisible: false
                lineVisible: false
                tickInterval: 80
                subTickCount: 4
                labelDecimals: 1
            }

            axisY: ValueAxis {
                id: yAxis
                min: -11
                max: 11
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
                    // Replace with your actual ECG data array for group 1 (ekgLine1)
                    ekgSeries.replace(ekgLine1.map((val, i) => Qt.point(i,
                                                                        val)))
                }
            }
            LineSeries {
                id: ekgSeries2
                width: 2
                capStyle: Qt.RoundCap
                color: "#000000"

                Component.onCompleted: {
                    // Replace with your actual ECG data array for group 2 (ekgLine2)
                    ekgSeries2.replace(ekgLine2.map((val, i) => Qt.point(i,
                                                                         val)))
                }
            }
            LineSeries {
                id: ekgSeries3
                width: 2
                capStyle: Qt.RoundCap
                color: "#000000"

                Component.onCompleted: {
                    // Replace with your actual ECG data array for group 3 (ekgLine3)
                    ekgSeries3.replace(ekgLine3.map((val, i) => Qt.point(i,
                                                                         val)))
                }
            }
        }
    }
    // --- 12 standard lead labels placed in a simple 4x3 arrangement ---
    // Adjust positions and font sizes as desired.
    Text {
        text: "I"
        x: 50
        y: 100
        font.pixelSize: 25
    }
    Text {
        text: "aVR"
        x: 204
        y: 100
        font.pixelSize: 25
    }
    Text {
        text: "V1"
        x: 400
        y: 100
        font.pixelSize: 25
    }
    Text {
        text: "V4"
        x: 595
        y: 100
        font.pixelSize: 25
    }

    Text {
        text: "II"
        x: 43
        y: 170
        font.pixelSize: 25
    }
    Text {
        text: "aVL"
        x: 204
        y: 170
        font.pixelSize: 25
    }
    Text {
        text: "V2"
        x: 400
        y: 170
        font.pixelSize: 25
    }
    Text {
        text: "V5"
        x: 595
        y: 170
        font.pixelSize: 25
    }
    Text {
        text: "III"
        x: 40
        y: 255
        font.pixelSize: 25
    }
    Text {
        text: "aVF"
        x: 204
        y: 255
        font.pixelSize: 25
    }
    Text {
        text: "V3"
        x: 400
        y: 255
        font.pixelSize: 25
    }
    Text {
        text: "V6"
        x: 595
        y: 255
        font.pixelSize: 25
    }
}
