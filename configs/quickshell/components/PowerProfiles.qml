pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import "../theme"
import "../services"
import "ui"

Dropdown {
    id: root

    readonly property var profiles: [
        {
            label: "Power Saver",
            profile: PowerProfile.PowerSaver,
            available: true
        },
        {
            label: "Balanced",
            profile: PowerProfile.Balanced,
            available: true
        },
        {
            label: "Performance",
            profile: PowerProfile.Performance,
            available: PowerProfiles.hasPerformanceProfile
        }
    ]

    function profileLabel(profile): string {
        switch (profile) {
        case PowerProfile.PowerSaver:
            return "Power Saver";
        case PowerProfile.Balanced:
            return "Balanced";
        case PowerProfile.Performance:
            return "Performance";
        default:
            return "Unknown";
        }
    }

    icon: "󰔐"
    title: Strings.tr(Strings.keys.power_profiles)
    subtitle: root.profileLabel(PowerProfiles.profile)
    showChevron: true

    Repeater {
        model: root.profiles

        Rectangle {
            required property var modelData
            required property int index
            property bool hovered: profileMouse.containsMouse
            property bool pressed: profileMouse.pressed
            readonly property bool active: PowerProfiles.profile === modelData.profile
            Layout.fillWidth: true
            Layout.preferredHeight: LayoutTheme.barWidgetHeight
            Layout.topMargin: index === 0 ? 4 : 0
            radius: Shape.radiusNormal
            color: active ? Colors.surfaceHover : (pressed ? Colors.surfacePressed : (hovered ? Colors.surfaceHover : "transparent"))

            Behavior on color {
                ColorAnimation {
                    duration: Animations.duration_hover
                    easing.type: Animations.easingStandard
                }
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: parent.modelData.available ? parent.modelData.label : parent.modelData.label + " - unavailable"
                color: parent.modelData.available ? Colors.text : Colors.textSubtle
                font.pixelSize: Typography.size
                font.family: Typography.family
                elide: Text.ElideRight
                width: parent.width - 36
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                visible: parent.active
                text: "󰄬"
                color: Colors.text
                font.pixelSize: Typography.size
                font.family: Typography.iconFamily
            }

            MouseArea {
                id: profileMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: parent.modelData.available ? Qt.PointingHandCursor : Qt.ArrowCursor
                enabled: parent.modelData.available
                onClicked: PowerProfiles.profile = parent.modelData.profile
            }
        }
    }
}
