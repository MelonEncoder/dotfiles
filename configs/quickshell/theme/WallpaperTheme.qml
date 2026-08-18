pragma Singleton

import Quickshell
import QtQuick

Singleton {
    property string wallpaper: "random"

    readonly property color windowBorder:
        Qt.rgba(1, 1, 1, 0.333)

    readonly property color caption:
        Qt.rgba(0, 0, 0, 0.733)
}
