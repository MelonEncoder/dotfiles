pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Hyprland
import Quickshell.Widgets
import "popups"
import "../theme"
import "../services"

Item {
    id: root

    readonly property var currentPlayer: MediaService.currentPlayer
    property bool expanded: false
    property bool hovered: headerMouse.containsMouse
    // Modes: "auto" (browser => player name, media apps => track), "player", "media"
    property string label_mode: "auto"

    implicitWidth: header.implicitWidth
    implicitHeight: LayoutTheme.barWidgetHeight
    visible: !!root.currentPlayer

    // ── Bar widget ─────────────────────────────────────────────────────────────

    ClippingRectangle {
        id: header
        radius: Shape.radiusNormal
        color: headerMouse.pressed ? Colors.surfacePressed : ((root.hovered || root.expanded) ? Colors.surfaceHover : Colors.surface)
        border.width: Shape.borderWidth
        border.color: Colors.border
        implicitHeight: LayoutTheme.barWidgetHeight
        clip: true

        // Collapsed: padding + icon + padding
        // Expanded:  padding + icon + padding + label + padding
        // Label x = collapsedWidth, so it is perfectly clipped when not shown
        implicitWidth: LayoutTheme.barWidgetPadding + glyphText.implicitWidth + LayoutTheme.barWidgetPadding + (root.hovered || root.expanded ? Math.min(labelText.implicitWidth, 140) + LayoutTheme.barWidgetPadding : 0)

        Behavior on color {
            ColorAnimation {
                duration: Animations.duration_hover
                easing.type: Animations.easingStandard
            }
        }

        Behavior on implicitWidth {
            NumberAnimation {
                duration: Animations.duration_normal
                easing.type: Animations.easingEmphasized
            }
        }

        Text {
            id: glyphText
            anchors.left: parent.left
            anchors.leftMargin: LayoutTheme.barWidgetPadding
            anchors.verticalCenter: parent.verticalCenter
            text: MediaService.appGlyph(root.currentPlayer)
            color: Colors.text
            font.pixelSize: Typography.icon
            font.family: Typography.iconFamily
        }

        Text {
            id: labelText
            anchors.left: glyphText.right
            anchors.leftMargin: LayoutTheme.barWidgetPadding
            anchors.verticalCenter: parent.verticalCenter
            text: MediaService.playerLabel(root.currentPlayer)
            color: Colors.text
            font.pixelSize: Typography.size
            font.family: Typography.family
        }

        MouseArea {
            id: headerMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.expanded = !root.expanded
        }
    }

    // ── Media player popup ─────────────────────────────────────────────────────

    HyprlandFocusGrab {
        active: root.expanded
        windows: [dropdown]
        onCleared: root.expanded = false
    }

    MediaPlayerPopup {
        id: dropdown
        anchorItem: root
        expanded: root.expanded
        onClose: root.expanded = false
    }
}
