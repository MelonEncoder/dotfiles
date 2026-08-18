pragma Singleton

import Quickshell
import QtQuick

Singleton {
    readonly property color overlay:
        Qt.rgba(0, 0, 0, 0.4)

    readonly property color searchActiveBorder:
        Qt.rgba(1, 1, 1, 0.533)

    readonly property color row:
        Qt.rgba(1, 1, 1, 0.102)

    readonly property color rowHover:
        Qt.rgba(1, 1, 1, 0.133)

    readonly property color rowSelected:
        Qt.rgba(1, 1, 1, 0.188)

    readonly property color iconBackground:
        Qt.rgba(1, 1, 1, 0.094)
}
