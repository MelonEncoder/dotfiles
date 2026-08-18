pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Hyprland
import "popups"
import "../services"
import "../theme"

Rectangle {
    id: root
    property bool expanded: false
    property bool hovered: clickArea.containsMouse
    property bool pressed: clickArea.pressed

    implicitWidth: osIcon.implicitWidth + (LayoutTheme.barWidgetPadding * 2)
    implicitHeight: LayoutTheme.barWidgetHeight
    radius: Shape.radiusNormal
    color: root.pressed ? Colors.surfacePressed : (root.hovered ? Colors.surfaceHover : Colors.surface)
    border.width: Shape.borderWidth
    border.color: Colors.border

    Behavior on color {
        ColorAnimation {
            duration: Animations.duration_hover
            easing.type: Animations.easingStandard
        }
    }

    Text {
        id: osIcon
        anchors.centerIn: parent
        text: SystemInfoService.distroIcon
        color: Colors.text
        font.pixelSize: Typography.icon
        font.family: Typography.iconFamily
    }

    MouseArea {
        id: clickArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.expanded = !root.expanded
    }

    HyprlandFocusGrab {
        active: root.expanded
        windows: [dropdown]
        onCleared: root.expanded = false
    }

    SystemInfoPopup {
        id: dropdown
        anchorItem: root
        expanded: root.expanded
        distroDisplay: SystemInfoService.distroDisplay
        distroIcon: SystemInfoService.distroIcon
        kernelDisplay: SystemInfoService.kernelDisplay
        versionDisplay: SystemInfoService.versionDisplay
        cpuDisplay: SystemInfoService.cpuDisplay
        gpuDisplay: SystemInfoService.gpuDisplay
        ramDisplay: SystemInfoService.ramDisplay
        storageDisplay: SystemInfoService.storageDisplay
        onClose: root.expanded = false
    }
}
