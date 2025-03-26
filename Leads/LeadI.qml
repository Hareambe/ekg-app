import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphs


/*
Item {
    width: 1000
    height: 600

    GraphsView {
        id: ekgGraph
        anchors.fill: parent
        anchors.margins: 0

        // Theme: Pink background, pink grid lines, black waveform
        theme: GraphsTheme {
            colorScheme: GraphsTheme.ColorScheme.Custom

            // Some Qt versions do not have gridEnabled. If you get an error, comment it out.
            backgroundVisible: true

            // gridEnabled: true
            backgroundColor: "#FFF0F0"

            // Pink grid lines
            grid.mainColor: "#EEAAAA" // “Big squares”
            grid.subColor: "#FFDADA" // “Small squares”

            // Make borders transparent (removes black frame in some versions)
            borderColors: ["transparent"]

            // The waveform color
            seriesColors: ["#000000"]

            // Possibly hide the legend if it appears:
            // legendVisible: false
        }

        axisX: ValueAxis {
            id: xAxis
            min: 0
            max: 4095

            // Hide axis line and numeric labels
            labelsVisible: false
            lineVisible: false

            // If your version supports them, these can further reduce any baseline:
            // baselineVisible: false
            // baseline: -999999

            // If your version supports them, these can hide ticks:
            // tickVisible: false
            // minorTickVisible: false
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

            // baselineVisible: false
            // baseline: -999999
            // tickVisible: false
            // minorTickVisible: false
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

                // Replace with your actual ECG data array (e.g. ekgLead1).
                // If your data is in a QML property, e.g. ekgLead1, do:
                ekgSeries.replace(ekgLead1.map((val, i) => Qt.point(i, val)))
            }
        }
    }

    // Optional label for "I". Place it as a sibling so it doesn't shrink the graph.
    Text {
        text: "I"
        color: "#000000"
        font.pixelSize: 50
        anchors.left: ekgGraph.left
        anchors.bottom: ekgGraph.bottom
        anchors.leftMargin: 100
        anchors.bottomMargin: 80
        z: 999 // ensure it's drawn on top
    }
}*/
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
                    ekgSeries.replace(ekgLead1.map((val, i) => Qt.point(i,
                                                                        val)))
                }
            }
        }
        Text {
            text: "I"
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
