pragma Singleton

import Quickshell
import QtQuick

Singleton {
    // Colors
    readonly property color base:
        Qt.rgba(0.098, 0.078, 0.078, 1)

    readonly property color scrim:
        Qt.rgba(0.098, 0.078, 0.078, 0.302)

    readonly property color error:
        Qt.rgba(0.8, 0.133, 0.133, 1)

    readonly property color placeholder:
        Qt.rgba(0, 0, 0, 0.651)

    // Layout
    readonly property int margin: 48
    readonly property int columnWidth: 400
    readonly property int columnSpacing: 50
    readonly property int headerSpacing: 0
    readonly property int columnOffset: -90

    // Typography
    readonly property string timeFontFamily: "JetBrains Mono"
    readonly property string bodyFontFamily: "JetBrains Mono"

    readonly property int timeFontSize: 68
    readonly property int dateFontSize: 18
    readonly property int inputFontSize: 16
    readonly property int statusFontSize: 14

    // Input
    readonly property int inputHeight: 50
    readonly property int inputRadius: Shape.radiusNormal * 2
    readonly property int inputBorderWidth: 5
    readonly property int inputPadding: 18
    readonly property int statusHeight: 24
}
