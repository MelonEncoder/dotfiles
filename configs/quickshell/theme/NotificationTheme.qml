pragma Singleton

import Quickshell
import QtQuick

Singleton {
    readonly property color iconBackground:
        Qt.rgba(1, 1, 1, 0.06)

    readonly property color action:
        Qt.rgba(1, 1, 1, 0.08)

    readonly property color actionHover:
        Qt.rgba(1, 1, 1, 0.16)

    readonly property color actionPressed:
        Qt.rgba(1, 1, 1, 0.05)

    readonly property color accentLow:
        Qt.rgba(0.498, 0.863, 0.541, 1)

    readonly property color accentNormal:
        Qt.rgba(0.941, 0.702, 0.353, 1)

    readonly property color accentCritical:
        Qt.rgba(0.937, 0.420, 0.420, 1)
}
