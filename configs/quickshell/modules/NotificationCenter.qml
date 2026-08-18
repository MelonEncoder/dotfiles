pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import "../services"
import "../components"
import "../theme"

Scope {
    id: root

    readonly property int default_timeout_ms: 7000
    readonly property bool use_notification_timeout: true
    readonly property bool expire_resident: false
    readonly property bool expire_critical: false

    readonly property int margin: 20
    readonly property int width: 380
    readonly property int min_height: 72
    readonly property int max_body_lines: 4
    readonly property int stack_gap_below_bar: 8
    readonly property int spacing: 6
    readonly property int padding: 12
    readonly property int inner_spacing: 6
    readonly property int action_spacing: 4
    readonly property int image_size: 28
    readonly property int action_height: Typography.jumbo
    readonly property int radius: Shape.radiusNormal
    readonly property int border_width: Shape.borderWidth
    readonly property int slide_offset: 28
    readonly property int top_accent_height: 2
    readonly property int image_max_height: 120
    readonly property int image_radius: Shape.radiusNormal

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel
            required property var modelData
            property int activeToastCount: 0

            screen: modelData
            visible: activeToastCount > 0
            color: "transparent"
            aboveWindows: true
            focusable: false
            exclusionMode: ExclusionMode.Ignore
            implicitHeight: activeToastCount > 0 ? notificationColumn.implicitHeight + root.margin : 0

            anchors {
                top: true
                left: true
                right: true
            }

            margins.top: LayoutTheme.barWidgetHeight + (LayoutTheme.barPadding * 2) + root.stack_gap_below_bar

            Item {
                anchors.fill: parent

                Column {
                    id: notificationColumn
                    anchors.top: parent.top
                    anchors.topMargin: root.margin
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: root.width
                    spacing: root.spacing

                    Repeater {
                        id: notificationRepeater
                        model: NotificationService.trackedNotifications

                        delegate: Item {
                            id: notificationItem
                            required property var modelData

                            property var notification: modelData
                            property bool closing: false
                            property bool toastHidden: false
                            property real barProgress: 0
                            property var visibleActions: {
                                var actions = notification.actions || [];
                                var filtered = [];
                                for (var i = 0; i < actions.length; i++) {
                                    var action = actions[i];
                                    var label = ((action.text || "") + "").trim().toLowerCase();
                                    if (label === "dismiss" || label === "close")
                                        continue;
                                    filtered.push(action);
                                }
                                return filtered;
                            }
                            property bool shouldAutoExpire: (!notification.resident || root.expire_resident) && (notification.urgency !== NotificationUrgency.Critical || root.expire_critical)
                            property int resolvedTimeout: {
                                if (!root.use_notification_timeout)
                                    return root.default_timeout_ms;
                                if (notification.expireTimeout <= 0)
                                    return root.default_timeout_ms;
                                return notification.expireTimeout;
                            }
                            implicitWidth: root.width
                            implicitHeight: Math.max(root.min_height, content.implicitHeight + (root.padding * 2) + root.top_accent_height)
                            width: implicitWidth
                            height: implicitHeight
                            visible: !toastHidden

                            Component.onCompleted: panel.activeToastCount++
                            Component.onDestruction: if (!toastHidden) panel.activeToastCount--
                            onToastHiddenChanged: if (toastHidden) panel.activeToastCount--

                            function beginClose() {
                                if (closing)
                                    return;
                                closing = true;
                                card.entered = false;
                                closeTimer.start();
                            }

                            // Drives the accent bar left→right over the timeout duration
                            NumberAnimation {
                                target: notificationItem
                                property: "barProgress"
                                from: 0
                                to: 1
                                duration: notificationItem.resolvedTimeout
                                running: notificationItem.shouldAutoExpire && notificationItem.resolvedTimeout > 0 && !notificationItem.closing
                                onFinished: notificationItem.beginClose()
                            }

                            // Waits for exit animation to finish, then hides the toast
                            // without removing the notification — it stays in the bell menu
                            Timer {
                                id: closeTimer
                                interval: Math.max(Animations.duration_slow, Animations.duration_normal) + 40
                                repeat: false
                                onTriggered: notificationItem.toastHidden = true
                            }

                            Rectangle {
                                id: card
                                property bool entered: false

                                width: parent.width
                                height: parent.height
                                radius: root.radius
                                clip: true
                                color: Colors.surface
                                border.width: root.border_width
                                border.color: Colors.border
                                opacity: entered ? 1 : 0
                                y: entered ? 0 : -(root.slide_offset + height)
                                scale: entered ? 1.0 : 0.97
                                transformOrigin: Item.Top

                                Behavior on y {
                                    NumberAnimation {
                                        duration: Animations.duration_slow
                                        easing.type: Animations.easingEmphasized
                                    }
                                }

                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: Animations.duration_normal
                                        easing.type: Animations.easingStandard
                                    }
                                }

                                Behavior on scale {
                                    NumberAnimation {
                                        duration: Animations.duration_slow
                                        easing.type: Animations.easingEmphasized
                                    }
                                }

                                Component.onCompleted: entered = true

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: notificationItem.beginClose()
                                }

                                Connections {
                                    target: notificationItem.notification

                                    function onClosed() {
                                        notificationItem.closing = true;
                                        card.entered = false;
                                        closeTimer.start();
                                    }
                                }

                                ColumnLayout {
                                    id: content
                                    anchors.fill: parent
                                    anchors.topMargin: root.padding
                                    anchors.leftMargin: root.padding
                                    anchors.rightMargin: root.padding
                                    anchors.bottomMargin: root.padding
                                    spacing: root.inner_spacing

                                    NotificationCard {
                                        Layout.fillWidth: true
                                        notification: notificationItem.notification
                                        progress: notificationItem.shouldAutoExpire ? notificationItem.barProgress : 1.0
                                        iconSize: root.image_size
                                        barHeight: root.top_accent_height
                                        rowSpacing: root.inner_spacing
                                    }

                                    Text {
                                        visible: text.length > 0
                                        text: notificationItem.notification.body || ""
                                        textFormat: Text.StyledText
                                        color: Colors.textMuted
                                        font.pixelSize: Typography.size
                                        font.family: Typography.family
                                        wrapMode: Text.Wrap
                                        maximumLineCount: root.max_body_lines
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Rectangle {
                                        visible: notificationImage.source.toString() !== ""
                                        Layout.fillWidth: true
                                        Layout.maximumHeight: visible ? root.image_max_height : 0
                                        Layout.minimumHeight: 0
                                        Layout.preferredHeight: visible ? implicitHeight : 0
                                        implicitHeight: notificationImage.status === Image.Ready ? Math.min(root.image_max_height, (notificationImage.implicitHeight > 0 ? notificationImage.implicitHeight : root.image_max_height)) : root.image_max_height
                                        radius: root.image_radius
                                        color: Colors.overlayDark
                                        clip: true

                                        Image {
                                            id: notificationImage
                                            anchors.fill: parent
                                            source: notificationItem.notification.image || ""
                                            fillMode: Image.PreserveAspectFit
                                            asynchronous: true
                                            cache: true
                                            smooth: true
                                            mipmap: true
                                            autoTransform: true
                                        }
                                    }

                                    RowLayout {
                                        visible: repeater.count > 0
                                        Layout.fillWidth: true
                                        spacing: root.action_spacing
                                        property var doClose: notificationItem.beginClose
                                        property bool hasIcons: notificationItem.notification.hasActionIcons

                                        Repeater {
                                            id: repeater
                                            model: notificationItem.visibleActions

                                            delegate: Rectangle {
                                                id: actionBtn
                                                required property var modelData

                                                readonly property var action: modelData
                                                readonly property string iconSource: parent.hasIcons
                                                    ? Quickshell.iconPath(action.identifier, "")
                                                    : ""

                                                implicitWidth: actionBtnContent.implicitWidth + (root.padding * 2)
                                                implicitHeight: root.action_height
                                                radius: Shape.radiusNormal
                                                color: actionMouse.pressed ? NotificationTheme.actionPressed : (actionMouse.containsMouse ? NotificationTheme.actionHover : NotificationTheme.action)

                                                Behavior on color {
                                                    ColorAnimation {
                                                        duration: Animations.duration_hover
                                                        easing.type: Animations.easingStandard
                                                    }
                                                }

                                                RowLayout {
                                                    id: actionBtnContent
                                                    anchors.centerIn: parent
                                                    spacing: 4

                                                    Image {
                                                        visible: actionBtn.iconSource !== ""
                                                        source: actionBtn.iconSource
                                                        Layout.preferredWidth: Typography.size
                                                        Layout.preferredHeight: Typography.size
                                                        fillMode: Image.PreserveAspectFit
                                                        smooth: true
                                                    }

                                                    Text {
                                                        text: actionBtn.action.text
                                                        color: Colors.text
                                                        font.pixelSize: Typography.size
                                                        font.family: Typography.family
                                                    }
                                                }

                                                MouseArea {
                                                    id: actionMouse
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    onClicked: {
                                                        actionBtn.action.invoke();
                                                        parent.parent.doClose();
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
