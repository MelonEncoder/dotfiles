pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
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
            text: ""
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

    PopupWindow {
        id: dropdown
        anchor.item: root
        anchor.rect.x: 0
        anchor.rect.y: LayoutTheme.barWidgetHeight + (LayoutTheme.barPadding * 2)
        visible: root.expanded
        implicitWidth: dropdown.screen.width
        implicitHeight: dropdown.screen.height
        color: "transparent"

        // Backdrop — click outside to dismiss
        Backdrop {
            expanded: root.expanded
            onClose: root.expanded = false
        }

        Rectangle {
            id: popupPanel
            readonly property int panelWidth: 320

            x: (dropdown.width - width) / 2
            y: LayoutTheme.barWidgetHeight + (LayoutTheme.barPadding * 2)
            width: panelWidth
            height: headerSection.implicitHeight + (LayoutTheme.barWidgetPadding * 2) + CalendarTheme.contentSpacing + notifFlickable.height
            radius: Shape.radiusBackground
            color: Colors.background
            border.width: Shape.borderWidth
            border.color: Colors.border
            opacity: root.expanded ? 1 : 0
            scale: root.expanded ? 1 : Animations.dropdownScaleClosed
            transformOrigin: Item.Top
            clip: true
            focus: root.expanded
            Keys.onEscapePressed: root.expanded = false

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

            // Absorb clicks so backdrop doesn't fire through the panel
            MouseArea {
                anchors.fill: parent
            }

            // ── Header ────────────────────────────────────────────────────

            Column {
                id: headerSection
                x: LayoutTheme.barWidgetPadding
                y: LayoutTheme.barWidgetPadding
                width: popupPanel.panelWidth - (LayoutTheme.barWidgetPadding * 2)
                spacing: CalendarTheme.contentSpacing

                RowLayout {
                    width: parent.width
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
                    width: parent.width
                    height: 1
                    color: Colors.borderSubtle
                }
            }

            // ── Notification list ──────────────────────────────────────────

            Flickable {
                id: notifFlickable
                anchors.top: headerSection.bottom
                anchors.topMargin: CalendarTheme.contentSpacing
                anchors.left: parent.left
                anchors.leftMargin: LayoutTheme.barWidgetPadding
                anchors.right: parent.right
                anchors.rightMargin: LayoutTheme.barWidgetPadding
                height: Math.min(notifList.implicitHeight, 400)
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
    }
}
