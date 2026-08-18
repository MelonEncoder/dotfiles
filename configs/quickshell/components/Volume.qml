pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../theme"
import "../services/"
import "ui"
// Adjust this import to wherever Slider.qml lives relative to this file
// (e.g. "../" or your shared widgets module) if it isn't in the same dir.

Rectangle {
    id: root

    readonly property int sectionMargin: Math.round(LayoutTheme.barWidgetPadding / 2)
    readonly property int expandedContentHeight: deviceColumn.implicitHeight

    // Local mirror of VolumeService.volume so dragging feels instant and
    // isn't fighting the (possibly slightly-lagged) Pipewire readback.
    property int currentVolume: 0
    property bool expanded: false

    Connections {
        target: VolumeService
        function onVolumeChanged() {
            if (!volumeSlider.dragging)
                root.currentVolume = VolumeService.volume;
        }
    }

    function setDefaultSink(node: var): void {
        VolumeService.setDefaultSink(node);
        root.expanded = false;
    }

    Component.onCompleted: root.currentVolume = VolumeService.volume

    implicitWidth: 280
    implicitHeight: volumeFrame.implicitHeight + (root.sectionMargin * 2)
    width: implicitWidth
    height: implicitHeight
    Layout.fillWidth: true
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight
    radius: Shape.radiusNormal
    color: Colors.surface

    Item {
        id: volumeFrame
        x: root.sectionMargin
        y: root.sectionMargin
        width: parent.width - (root.sectionMargin * 2)
        implicitHeight: volumeMenu.implicitHeight

        ColumnLayout {
            id: volumeMenu
            width: parent.width
            spacing: 4

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: LayoutTheme.barWidgetHeight * 1.5
                radius: Shape.radiusNormal
                color: "transparent"

                RowLayout {
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: 10
                        rightMargin: 10
                    }
                    spacing: 10

                    Rectangle {
                        id: muteButton
                        property bool hovered: muteButtonMouse.containsMouse
                        property bool pressed: muteButtonMouse.pressed
                        implicitWidth: LayoutTheme.barWidgetHeight
                        implicitHeight: LayoutTheme.barWidgetHeight
                        Layout.alignment: Qt.AlignVCenter
                        radius: Shape.radiusNormal
                        color: muteButton.pressed ? Colors.surfacePressed : (muteButton.hovered ? Colors.surfaceHover : "transparent")

                        Behavior on color {
                            ColorAnimation {
                                duration: Animations.duration_hover
                                easing.type: Animations.easingStandard
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: !VolumeService.sink ? "" : (VolumeService.muted ? "" : "")
                            color: Colors.text
                            font.pixelSize: Typography.icon
                            font.family: Typography.iconFamily
                        }

                        MouseArea {
                            id: muteButtonMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: VolumeService.toggleMute()
                        }
                    }

                    Slider {
                        id: volumeSlider
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        value: root.currentVolume
                        onMoved: function (percent) {
                            root.currentVolume = percent;
                            VolumeService.setVolume(percent);
                        }
                    }

                    Rectangle {
                        id: deviceToggle
                        property bool hovered: deviceToggleMouse.containsMouse
                        property bool pressed: deviceToggleMouse.pressed
                        Layout.alignment: Qt.AlignVCenter
                        implicitWidth: LayoutTheme.barWidgetHeight
                        implicitHeight: LayoutTheme.barWidgetHeight
                        radius: Shape.radiusNormal
                        color: root.expanded || deviceToggle.pressed ? Colors.surfacePressed : (deviceToggle.hovered ? Colors.surfaceHover : "transparent")

                        Behavior on color {
                            ColorAnimation {
                                duration: Animations.duration_hover
                                easing.type: Animations.easingStandard
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: root.expanded ? "\uf077" : "\uf078"
                            color: root.expanded ? Colors.text : Colors.textSubtle
                            font.pixelSize: Typography.iconLg
                            font.family: Typography.iconFamily
                        }

                        MouseArea {
                            id: deviceToggleMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.expanded = !root.expanded
                        }
                    }
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
                    id: deviceColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 3

                    Text {
                        text: Strings.tr(Strings.keys.output_devices)
                        color: Colors.textSubtle
                        font.pixelSize: Typography.size
                        font.family: Typography.family
                        Layout.fillWidth: true
                        Layout.topMargin: 4
                    }

                    Repeater {
                        model: VolumeService.audioSinks

                        Rectangle {
                            id: deviceItem
                            required property var modelData
                            readonly property bool isDefault: !!VolumeService.sink && modelData.id === VolumeService.sink.id
                            property bool hovered: deviceMouse.containsMouse
                            property bool pressed: deviceMouse.pressed

                            Layout.fillWidth: true
                            Layout.preferredHeight: LayoutTheme.barWidgetHeight
                            radius: Shape.radiusNormal
                            color: deviceItem.pressed ? Colors.surfacePressed : (deviceItem.hovered || deviceItem.isDefault ? Colors.surfaceHover : "transparent")

                            Behavior on color {
                                ColorAnimation {
                                    duration: Animations.duration_hover
                                    easing.type: Animations.easingStandard
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 8

                                Text {
                                    text: deviceItem.isDefault ? "" : ""
                                    color: deviceItem.isDefault ? Colors.text : Colors.textSubtle
                                    font.pixelSize: Typography.sm
                                    font.family: Typography.iconFamily
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                Text {
                                    text: deviceItem.modelData.description || deviceItem.modelData.nick || deviceItem.modelData.name || "Unknown"
                                    color: Colors.text
                                    font.pixelSize: Typography.size
                                    font.family: Typography.family
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                }
                            }

                            MouseArea {
                                id: deviceMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.setDefaultSink(deviceItem.modelData)
                            }
                        }
                    }
                }
            }
        }
    }
}
