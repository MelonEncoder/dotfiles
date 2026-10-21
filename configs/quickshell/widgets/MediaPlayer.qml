pragma ComponentBehavior: Bound

import QtQuick
import "../components/popups"
import "../components/ui"
import "../theme"
import "../services"

BarButton {
    id: root

    readonly property var currentPlayer: MediaService.currentPlayer
    // Modes: "auto" (browser => player name, media apps => track), "player", "media"
    property string label_mode: "auto"

    visible: !!root.currentPlayer
    clip: true
    popup: MediaPlayerPopup {}

    // Collapsed: padding + icon + padding
    // Expanded:  padding + icon + padding + label + padding
    // Label x = collapsedWidth, so it is perfectly clipped when not shown
    implicitWidth: LayoutTheme.barWidgetPadding + glyphText.implicitWidth + LayoutTheme.barWidgetPadding + (root.hovered || root.expanded ? Math.min(labelText.implicitWidth, 140) + LayoutTheme.barWidgetPadding : 0)

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
}
