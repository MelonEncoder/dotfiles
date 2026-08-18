pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import "../theme"
import "../services"

Rectangle {
    id: root
    property bool expanded: false
    readonly property int sectionMargin: Math.round(LayoutTheme.barWidgetPadding / 2)
    readonly property int expandedContentHeight: powerProfilesExpandedContent.implicitHeight

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

    implicitWidth: 280
    implicitHeight: powerProfilesFrame.implicitHeight + (root.sectionMargin * 2)
    width: implicitWidth
    height: implicitHeight
    Layout.fillWidth: true
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight
    radius: Shape.radiusNormal
    color: Colors.surface

    Item {
        id: powerProfilesFrame
        x: root.sectionMargin
        y: root.sectionMargin
        width: parent.width - (root.sectionMargin * 2)
        implicitHeight: powerProfilesMenu.implicitHeight

        ColumnLayout {
            id: powerProfilesMenu
            width: parent.width
            spacing: 4

            Rectangle {
                id: powerProfilesHeader
                property bool hovered: powerProfilesHeaderMouse.containsMouse
                property bool pressed: powerProfilesHeaderMouse.pressed
                Layout.fillWidth: true
                Layout.preferredHeight: LayoutTheme.barWidgetHeight * 1.5
                radius: Shape.radiusNormal
                color: pressed ? Colors.surfacePressed : Colors.surfaceHover

                Behavior on color {
                    ColorAnimation {
                        duration: Animations.duration_hover
                        easing.type: Animations.easingStandard
                    }
                }

                RowLayout {
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: 10
                        rightMargin: 10
                    }
                    spacing: 12

                    Text {
                        text: "󰔐"
                        color: Colors.text
                        font.pixelSize: Typography.icon
                        font.family: Typography.iconFamily
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Column {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 1

                        Text {
                            text: Strings.tr(Strings.keys.power_profiles)
                            color: Colors.text
                            font.pixelSize: Typography.size
                            font.family: Typography.family
                        }

                        Text {
                            text: root.profileLabel(PowerProfiles.profile)
                            color: Colors.textSubtle
                            font.pixelSize: Typography.size
                            font.family: Typography.family
                        }
                    }

                    Text {
                        text: root.expanded ? "" : ""
                        color: Colors.textSubtle
                        font.pixelSize: Typography.xs
                        font.family: Typography.iconFamily
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                MouseArea {
                    id: powerProfilesHeaderMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.expanded = !root.expanded
                }
            }

            Item {
                visible: root.expanded || opacity > 0.01
                Layout.fillWidth: true
                Layout.preferredHeight: root.expanded ? root.expandedContentHeight : 0
                implicitHeight: root.expanded ? root.expandedContentHeight : 0
                opacity: root.expanded ? 1 : 0
                clip: true

                Behavior on Layout.preferredHeight {
                    NumberAnimation {
                        duration: Animations.dropdownSection
                        easing.type: Animations.easingEmphasized
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Animations.dropdownSection
                        easing.type: Animations.easingEmphasized
                    }
                }

                ColumnLayout {
                    id: powerProfilesExpandedContent
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 3

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
            }
        }
    }
}
