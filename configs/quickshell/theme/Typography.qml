pragma Singleton

import Quickshell
import QtQuick

Singleton {
    // Families
    readonly property string family: "JetBrainsMono"
    readonly property string iconFamily: "Symbols Nerd Font"

    // Base
    readonly property int size: 12

    // Sizes
    readonly property int xs: size - 2
    readonly property int sm: size - 1
    readonly property int iconSm: size + 1
    readonly property int icon: size + 2
    readonly property int title: size + 3
    readonly property int iconLg: size + 4
    readonly property int xl: size + 5
    readonly property int xxl: size + 6
    readonly property int jumbo: size + 10
}
