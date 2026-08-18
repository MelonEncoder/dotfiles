pragma Singleton

import Quickshell
import QtQuick

Singleton {
    // Durations
    readonly property int duration_fast: 140
    readonly property int duration_hover: 100
    readonly property int duration_normal: 220
    readonly property int duration_slow: 320

    // Component-specific durations
    readonly property int dropdown: 180
    readonly property int dropdownSection: 200

    // Easing
    readonly property int easingStandard: Easing.InOutCubic
    readonly property int easingEmphasized: Easing.OutCubic

    // Transforms
    readonly property real dropdownScaleClosed: 0.96
    readonly property int dropdownOffset: 10
}
