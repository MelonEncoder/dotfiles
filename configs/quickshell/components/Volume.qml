pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../theme"
import "../services/"
// Adjust this import to wherever Slider.qml lives relative to this file
// (e.g. "../" or your shared widgets module) if it isn't in the same dir.

Rectangle {
    id: root

    readonly property int sectionMargin: Math.round(Theme.bar_widget_padding / 2)
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
    radius: Theme.radius_normal
    color: Theme.color_surface

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
                Layout.preferredHeight: Theme.bar_widget_height * 1.5
                radius: Theme.radius_normal
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
                        implicitWidth: Theme.bar_widget_height
                        implicitHeight: Theme.bar_widget_height
                        Layout.alignment: Qt.AlignVCenter
                        radius: Theme.radius_normal
                        color: muteButton.pressed ? Theme.color_surface_pressed : (muteButton.hovered ? Theme.color_surface_hover : "transparent")

                        Behavior on color {
                            ColorAnimation {
                                duration: Animations.duration_hover
                                easing.type: Animations.easing_standard
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: !VolumeService.sink ? "" : (VolumeService.muted ? "" : "")
                            color: Theme.color_text
                            font.pixelSize: Theme.font_size_icon
                            font.family: Theme.font_family_icon
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
                        implicitWidth: Theme.bar_widget_height
                        implicitHeight: Theme.bar_widget_height
                        radius: Theme.radius_normal
                        color: root.expanded || deviceToggle.pressed ? Theme.color_surface_pressed : (deviceToggle.hovered ? Theme.color_surface_hover : "transparent")

                        Behavior on color {
                            ColorAnimation {
                                duration: Animations.duration_hover
                                easing.type: Animations.easing_standard
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: root.expanded ? "\uf077" : "\uf078"
                            color: root.expanded ? Theme.color_text : Theme.color_text_subtle
                            font.pixelSize: Theme.font_size_icon_lg
                            font.family: Theme.font_family_icon
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
                        duration: Animations.duration_dropdown_section
                        easing.type: Animations.easing_emphasized
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Animations.duration_dropdown_section
                        easing.type: Animations.easing_emphasized
                    }
                }

                ColumnLayout {
                    id: deviceColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 3

                    Text {
                        text: Strings.tr(Strings.keys.output_devices)
                        color: Theme.color_text_subtle
                        font.pixelSize: Theme.font_size
                        font.family: Theme.font_family
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
                            Layout.preferredHeight: Theme.bar_widget_height
                            radius: Theme.radius_normal
                            color: deviceItem.pressed ? Theme.color_surface_pressed : (deviceItem.hovered || deviceItem.isDefault ? Theme.color_surface_hover : "transparent")

                            Behavior on color {
                                ColorAnimation {
                                    duration: Animations.duration_hover
                                    easing.type: Animations.easing_standard
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 8

                                Text {
                                    text: deviceItem.isDefault ? "" : ""
                                    color: deviceItem.isDefault ? Theme.color_text : Theme.color_text_subtle
                                    font.pixelSize: Theme.font_size_sm
                                    font.family: Theme.font_family_icon
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                Text {
                                    text: deviceItem.modelData.description || deviceItem.modelData.nick || deviceItem.modelData.name || "Unknown"
                                    color: Theme.color_text
                                    font.pixelSize: Theme.font_size
                                    font.family: Theme.font_family
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
