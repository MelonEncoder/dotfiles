pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import "popups"
import "ui"
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

    PopupWindow {
        id: dropdown
        anchor.item: root
        visible: root.expanded
        implicitWidth: dropdown.screen.width
        implicitHeight: dropdown.screen.height
        color: "transparent"

        Backdrop {
            expanded: root.expanded
            onClose: root.expanded = false
        }

        Rectangle {
            id: popupPanel
            readonly property int contentWidth: 240

            x: root.mapToGlobal(root.width / 2, 0).x - width / 2
            y: LayoutTheme.barWidgetHeight + (LayoutTheme.barPadding * 2)
            width: contentWidth + (LayoutTheme.barWidgetPadding * 2)
            height: popupColumn.implicitHeight + (LayoutTheme.barWidgetPadding * 2)
            radius: Shape.radiusBackground
            color: Colors.background
            border.width: Shape.borderWidth
            border.color: Colors.border
            opacity: root.expanded ? 1 : 0
            scale: root.expanded ? 1 : Animations.dropdownScaleClosed
            focus: root.expanded
            Keys.onEscapePressed: root.expanded = false
            transformOrigin: Item.Top

            Behavior on opacity {
                NumberAnimation {
                    duration: Animations.dropdown
                    easing.type: Animations.easingEmphasized
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: Animations.dropdown
                    easing.type: Animations.easingEmphasized
                }
            }

            // Absorb clicks so the backdrop doesn't fire through the panel
            MouseArea {
                anchors.fill: parent
            }

            Column {
                id: popupColumn
                x: LayoutTheme.barWidgetPadding
                y: LayoutTheme.barWidgetPadding
                width: popupPanel.contentWidth
                spacing: 8

                // ── Header label ───────────────────────────────────────────────

                Text {
                    text: Strings.tr(Strings.keys.media)
                    color: Colors.textSubtle
                    font.pixelSize: Typography.xs
                    font.family: Typography.family
                    font.capitalization: Font.AllUppercase
                    font.letterSpacing: 1
                    leftPadding: 2
                    bottomPadding: 2
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Colors.borderSubtle
                }

                // ── Album art ──────────────────────────────────────────────────

                Rectangle {
                    width: parent.width
                    height: (artImage.status === Image.Ready && artImage.sourceSize.width > 0)
                        ? Math.round(parent.width * artImage.sourceSize.height / artImage.sourceSize.width)
                        : parent.width
                    radius: Shape.radiusNormal
                    color: Colors.surface
                    clip: true

                    Image {
                        id: artImage
                        anchors.fill: parent
                        source: root.currentPlayer && root.currentPlayer.trackArtUrl ? root.currentPlayer.trackArtUrl : ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        visible: status === Image.Ready
                    }

                    Text {
                        anchors.centerIn: parent
                        text: MediaService.appGlyph(root.currentPlayer)
                        color: Colors.textMuted
                        font.pixelSize: Typography.jumbo
                        font.family: Typography.iconFamily
                        visible: artImage.status !== Image.Ready
                    }
                }

                // ── Track info ─────────────────────────────────────────────────

                Column {
                    width: parent.width
                    spacing: 2
                    leftPadding: 2

                    Text {
                        width: parent.width - parent.leftPadding
                        text: root.currentPlayer ? (root.currentPlayer.trackTitle || MediaService.playerLabel(root.currentPlayer)) : Strings.tr(Strings.keys.no_media)
                        color: Colors.text
                        font.pixelSize: Typography.size
                        font.family: Typography.family
                        elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width - parent.leftPadding
                        text: root.currentPlayer ? (root.currentPlayer.trackArtist || root.currentPlayer.trackArtists || "") : ""
                        color: Colors.textMuted
                        font.pixelSize: Typography.sm
                        font.family: Typography.family
                        elide: Text.ElideRight
                        visible: text.length > 0
                    }
                }

                // ── Progress bar + timestamps ──────────────────────────────────

                Column {
                    width: parent.width
                    spacing: 4

                    ProgressBar {
                        width: parent.width
                        value: MediaService.displayPosition
                        maximum: root.currentPlayer ? MediaService.normalizeTime(root.currentPlayer.length) : 0
                    }

                    RowLayout {
                        width: parent.width

                        Text {
                            text: MediaService.formatTime(MediaService.displayPosition)
                            color: Colors.textMuted
                            font.pixelSize: Typography.xs
                            font.family: Typography.family
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: root.currentPlayer ? MediaService.formatTime(MediaService.normalizeTime(root.currentPlayer.length)) : "0:00"
                            color: Colors.textMuted
                            font.pixelSize: Typography.xs
                            font.family: Typography.family
                        }
                    }
                }

                // ── Playback controls ──────────────────────────────────────────

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 6
                    bottomPadding: 2

                    LabelButton {
                        icon: "󰒮"
                        size: 32
                        enabled: !!root.currentPlayer && root.currentPlayer.canGoPrevious
                        onClicked: MediaService.previous()
                    }

                    LabelButton {
                        icon: (root.currentPlayer && root.currentPlayer.isPlaying) ? "󰏤" : "󰐊"
                        size: 36
                        bordered: true
                        onClicked: MediaService.toggleCurrentPlayer()
                    }

                    LabelButton {
                        icon: "󰒭"
                        size: 32
                        enabled: !!root.currentPlayer && root.currentPlayer.canGoNext
                        onClicked: MediaService.next()
                    }
                }
            }
        }
    }
}
