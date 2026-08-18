pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import ".."
import "../surfaces"
import "../../theme"
import "../../services"

BarPopupSurface {
    id: root

    required property Item anchorItem

    // Reactive notification count — .length on a QML model list is not reactive,
    // but Repeater.count is updated by the model's own change signals.
    Repeater {
        id: countRepeater
        model: NotificationService.trackedNotifications
        delegate: Item {}
    }

    anchor.item: anchorItem
    anchor.rect.x: 0
    anchor.rect.y: LayoutTheme.barWidgetHeight + (LayoutTheme.barPadding * 2)
    contentSpacing: CalendarTheme.contentSpacing

    panelX: (root.width - panelWidth) / 2
    panelY: LayoutTheme.barWidgetHeight + (LayoutTheme.barPadding * 2)
    panelWidth: 320

    // ── Header ────────────────────────────────────────────────────────────
    ColumnLayout {
        Layout.fillWidth: true
        spacing: CalendarTheme.contentSpacing

        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            Text {
                text: Strings.tr(Strings.keys.notifications)
                color: Colors.textSubtle
                font.pixelSize: Typography.xs
                font.family: Typography.family
                font.letterSpacing: 1
                leftPadding: 2
                bottomPadding: 2
            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                visible: countRepeater.count > 0
                text: Strings.tr(Strings.keys.clear_all)
                color: clearMouse.containsMouse ? Colors.text : Colors.textSubtle
                font.pixelSize: Typography.xs
                font.family: Typography.family
                rightPadding: 2
                bottomPadding: 2

                Behavior on color {
                    ColorAnimation {
                        duration: Animations.duration_hover
                        easing.type: Animations.easingStandard
                    }
                }

                MouseArea {
                    id: clearMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var list = NotificationService.trackedNotifications;
                        for (var i = list.length - 1; i >= 0; i--)
                            list[i].dismiss();
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Colors.borderSubtle
        }
    }

    // ── Notification list ────────────────────────────────────────────────
    Flickable {
        id: notifFlickable
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(notifList.implicitHeight, 400)
        contentHeight: notifList.implicitHeight
        clip: true

        Column {
            id: notifList
            width: parent.width
            spacing: CalendarTheme.contentSpacing

            // Empty state
            Text {
                visible: countRepeater.count === 0
                width: parent.width
                text: Strings.tr(Strings.keys.no_notifications)
                color: Colors.textSubtle
                font.pixelSize: Typography.sm
                font.family: Typography.family
                horizontalAlignment: Text.AlignHCenter
                topPadding: 6
                bottomPadding: 6
            }

            // Notification cards
            Repeater {
                model: NotificationService.trackedNotifications

                delegate: Rectangle {
                    id: notifCard
                    required property var modelData

                    width: notifList.width
                    implicitHeight: cardContent.implicitHeight + 18
                    radius: Shape.radiusNormal
                    color: cardMouse.containsMouse ? Colors.surfaceHover : Colors.surface
                    clip: true

                    Behavior on color {
                        ColorAnimation {
                            duration: Animations.duration_hover
                            easing.type: Animations.easingStandard
                        }
                    }

                    Column {
                        id: cardContent
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        anchors.topMargin: 10
                        spacing: 2

                        NotificationCard {
                            width: parent.width
                            notification: notifCard.modelData
                            iconSize: 24
                            summaryFontSize: Typography.sm
                            rowSpacing: 4
                        }

                        Text {
                            visible: text.length > 0
                            text: notifCard.modelData.body || ""
                            textFormat: Text.StyledText
                            color: Colors.textMuted
                            font.pixelSize: Typography.xs
                            font.family: Typography.family
                            wrapMode: Text.Wrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                            width: parent.width
                        }

                        Rectangle {
                            visible: bellImage.source.toString() !== ""
                            width: parent.width
                            height: visible ? 80 : 0
                            radius: Shape.radiusNormal
                            color: Colors.overlayDark
                            clip: true

                            Image {
                                id: bellImage
                                anchors.fill: parent
                                source: notifCard.modelData.image || ""
                                fillMode: Image.PreserveAspectFit
                                asynchronous: true
                                smooth: true
                                mipmap: true
                            }
                        }
                    }

                    // Click card to dismiss
                    MouseArea {
                        id: cardMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: notifCard.modelData.dismiss()
                    }
                }
            }
        }
    }
}
