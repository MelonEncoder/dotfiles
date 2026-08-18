pragma Singleton

import Quickshell
import QtQuick

Singleton {
    // Colors
    readonly property color sunday:
        Qt.rgba(0.878, 0.424, 0.455, 1)

    readonly property color saturday:
        Qt.rgba(0.380, 0.686, 0.937, 1)

    // Dimensions
    readonly property int cellWidth: 32
    readonly property int cellHeight: 28
    readonly property int headerHeight: 22
    readonly property int todaySize: 22
    readonly property int navigationHeight: 24
    readonly property int contentSpacing: 6
}
