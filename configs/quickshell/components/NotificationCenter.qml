pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Hyprland
import "../services"
import "popups"
import "../theme"

Item {
    id: root
    property bool expanded: false

    implicitWidth: widget.implicitWidth
    implicitHeight: LayoutTheme.barWidgetHeight
    visible: countRepeater.count > 0

    // Reactive notification count — .length on a QML model list is not reactive,
    // but Repeater.count is updated by the model's own change signals.
    Repeater {
        id: countRepeater
        model: NotificationService.trackedNotifications
        delegate: Item {}
    }

    // ── Bar widget ──────────────────────────────────────────────────────────

    Rectangle {
        id: widget
        radius: Shape.radiusNormal
        color: widgetMouse.pressed ? Colors.surfacePressed : (widgetMouse.containsMouse ? Colors.surfaceHover : Colors.surface)
        border.width: Shape.borderWidth
        border.color: Colors.border
        implicitWidth: bellIcon.implicitWidth + (LayoutTheme.barWidgetPadding * 2)
        implicitHeight: LayoutTheme.barWidgetHeight

        Behavior on color {
            ColorAnimation {
                duration: Animations.duration_hover
                easing.type: Animations.easingStandard
            }
        }

        Text {
            id: bellIcon
            anchors.centerIn: parent
            text: ""
            color: Colors.text
            font.pixelSize: Typography.icon
            font.family: Typography.iconFamily
        }

        MouseArea {
            id: widgetMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.expanded = !root.expanded
        }
    }

    // ── Notification history popup ──────────────────────────────────────────

    HyprlandFocusGrab {
        active: root.expanded
        windows: [dropdown]
        onCleared: root.expanded = false
    }

    NotificationBellPopup {
        id: dropdown
        anchorItem: root
        expanded: root.expanded
        onClose: root.expanded = false
    }
}
