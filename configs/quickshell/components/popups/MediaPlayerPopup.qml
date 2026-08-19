pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import "../surfaces"
import "../ui"
import "../../theme"
import "../../services"

BarPopupSurface {
    id: root

    required property Item anchorItem
    readonly property var currentPlayer: MediaService.currentPlayer
    readonly property int popupContentWidth: 240

    anchor.item: anchorItem
    text: Strings.tr(Strings.keys.media)
    contentSpacing: 8

    panelX: anchorItem.mapToGlobal(anchorItem.width / 2, 0).x - panelWidth / 2
    panelY: LayoutTheme.barWidgetHeight + (LayoutTheme.barPadding * 2)
    panelWidth: root.popupContentWidth + (LayoutTheme.barWidgetPadding * 2)

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
        Layout.alignment: Qt.AlignHCenter
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
