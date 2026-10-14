pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.UPower
import "../theme"

Rectangle {
    id: root
    readonly property var batteryDevice: UPower.displayDevice
    readonly property bool hasBattery: !!batteryDevice && batteryDevice.ready && batteryDevice.isPresent && batteryDevice.isLaptopBattery
    readonly property int batteryPercent: batteryDevice ? clampPercent(Math.round(batteryDevice.percentage)) : 0
    readonly property bool charging: root.hasBattery && !UPower.onBattery

    visible: root.hasBattery
    implicitWidth: content.implicitWidth + (LayoutTheme.barWidgetPadding * 2)
    implicitHeight: LayoutTheme.barWidgetHeight
    radius: Shape.radiusNormal
    color: Colors.surface
    border.width: Shape.borderWidth
    border.color: Colors.border

    function clampPercent(value: int): int {
        return Math.max(0, Math.min(100, value));
    }

    function levelIcon(percent: int): string {
        var p = clampPercent(percent);
        if (p <= 20)
            return "";
        if (p <= 40)
            return "";
        if (p <= 60)
            return "";
        if (p <= 80)
            return "";
        return "";
    }

    function batteryIcon(percent: int, isCharging: bool): string {
        if (isCharging)
            return "";
        return levelIcon(percent);
    }

    Item {
        id: content
        anchors.centerIn: parent
        implicitWidth: iconLabel.implicitWidth + 6 + valueLabel.implicitWidth
        implicitHeight: Math.max(iconLabel.implicitHeight, valueLabel.implicitHeight)

        Text {
            id: iconLabel
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: root.batteryIcon(root.batteryPercent, root.charging)
            color: root.batteryPercent <= 15 ? Colors.privacy : Colors.text
            font.pixelSize: Typography.size
            font.family: Typography.iconFamily
        }

        Text {
            id: valueLabel
            anchors.left: iconLabel.right
            anchors.leftMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            text: root.batteryPercent + "%"
            color: root.batteryPercent <= 15 ? Colors.privacy : Colors.text
            font.pixelSize: Typography.size
            font.family: Typography.family
        }
    }
}
