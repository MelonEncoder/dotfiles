pragma Singleton

import Quickshell
import QtQuick

Singleton {
    property string wallpaper: "random"

    readonly property color caption:
        Qt.rgba(0, 0, 0, 0.733)
}
