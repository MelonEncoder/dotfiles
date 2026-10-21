pragma Singleton

import Quickshell
import QtQuick

Singleton {
    // Radius
    readonly property int radiusBackground: 4
    readonly property int radiusNormal: 8
    readonly property int radiusLarge: 16

    // Width
    readonly property int borderWidth: 1

    // Shadow
    readonly property int shadowBlur: 16
    readonly property int shadowOffsetY: 0
}
