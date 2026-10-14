pragma ComponentBehavior: Bound

import QtQuick
import "../services"
import "../components/popups"
import "../theme"

BarButton {
    id: root

    implicitWidth: bellIcon.implicitWidth + (LayoutTheme.barWidgetPadding * 2)
    visible: countRepeater.count > 0
    popup: NotificationCenterPopup {}

    // Reactive notification count — .length on a QML model list is not reactive,
    // but Repeater.count is updated by the model's own change signals.
    Repeater {
        id: countRepeater
        model: NotificationService.trackedNotifications
        delegate: Item {}
    }

    Text {
        id: bellIcon
        anchors.centerIn: parent
        text: "󰂚"
        color: Colors.text
        font.pixelSize: Typography.icon
        font.family: Typography.iconFamily
    }
}
