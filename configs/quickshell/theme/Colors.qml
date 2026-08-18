pragma Singleton

import Quickshell
import QtQuick

Singleton {
    // Base colors
    readonly property color red: "#f8a8a8"
    readonly property color orange: "#fbc490"
    readonly property color yellow: "#fde68a"
    readonly property color green: "#a7e8b8"
    readonly property color blue: "#a8c8f0"
    readonly property color purple: "#8b5cf6"
    readonly property color violet: "#c9b6f5"

    // Accent
    readonly property color accentPrimary: purple
    readonly property color accentSecondary: "#06b6d4"

    // Base
    readonly property color background: Qt.rgba(0, 0, 0, 1)
    readonly property color surface: Qt.rgba(0.184, 0.184, 0.184, 1)
    readonly property color surfaceHover: Qt.rgba(0.267, 0.267, 0.267, 1)
    readonly property color surfacePressed: Qt.rgba(0.227, 0.227, 0.227, 1)

    // Borders / overlays
    readonly property color border: Qt.rgba(1, 1, 1, 0.4)
    readonly property color borderSubtle: Qt.rgba(1, 1, 1, 0.267)
    readonly property color overlayLight: Qt.rgba(1, 1, 1, 0.2)
    readonly property color overlayDark: Qt.rgba(0, 0, 0, 0.078)

    // Text
    readonly property color text: Qt.rgba(1, 1, 1, 1)
    readonly property color textMuted: Qt.rgba(0.851, 0.851, 0.851, 1)
    readonly property color textSubtle: Qt.rgba(0.749, 0.749, 0.749, 1)

    // Semantic
    readonly property color privacy: Qt.rgba(0.937, 0.475, 0.263, 1)
}
