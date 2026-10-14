pragma Singleton

import Quickshell
import QtQuick

Singleton {
    // Colors
    readonly property color weekend: Colors.accentPrimary
    readonly property color outsideMonth: Qt.rgba(1, 1, 1, 0.3)

    // Dimensions
    readonly property int cellWidth: 32
    readonly property int cellHeight: 28
    readonly property int headerHeight: 22
    readonly property int todaySize: 22
    readonly property int navigationHeight: 24
    readonly property int contentSpacing: 6
}
