pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../theme"
import "../services/"
import "ui"

Dropdown {
    id: root

    // Local mirror of AudioService.volume (as a 0-100 percent) so dragging
    // feels instant and isn't fighting the slightly-lagged wpctl readback.
    property int currentVolume: 0

    function setDefaultSink(node: var): void {
        AudioService.setDefaultSink(node);
        root.expanded = false;
    }

    function volumePercent(): int {
        return Math.max(0, Math.min(100, Math.round(AudioService.volume * 100)));
    }

    Component.onCompleted: root.currentVolume = root.volumePercent()

    headerDelegate: Component {
        Item {
            anchors.fill: parent

            RowLayout {
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    leftMargin: 10
                    rightMargin: 10
                }
                spacing: 10

                LabelButton {
                    Layout.alignment: Qt.AlignVCenter
                    baseColor: "transparent"
                    icon: !AudioService.sink ? "" : (AudioService.muted ? "" : "")
                    onClicked: AudioService.toggleMute()
                }

                Slider {
                    id: volumeSlider
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    value: root.currentVolume
                    onMoved: function (percent) {
                        root.currentVolume = percent;
                        AudioService.setVolume(percent / 100);
                    }

                    Connections {
                        target: AudioService
                        function onVolumeChanged() {
                            if (!volumeSlider.dragging)
                                root.currentVolume = root.volumePercent();
                        }
                    }
                }

                LabelButton {
                    Layout.alignment: Qt.AlignVCenter
                    baseColor: "transparent"
                    active: root.expanded
                    icon: root.expanded ? "\uf077" : "\uf078"
                    iconSize: Typography.iconLg
                    iconColor: root.expanded ? Colors.text : Colors.textSubtle
                    onClicked: root.expanded = !root.expanded
                }
            }
        }
    }

    Text {
        text: Strings.tr(Strings.keys.output_devices)
        color: Colors.textSubtle
        font.pixelSize: Typography.size
        font.family: Typography.family
        Layout.fillWidth: true
        Layout.topMargin: 4
    }

    Repeater {
        model: AudioService.audioSinks

        Rectangle {
            id: deviceItem
            required property var modelData
            readonly property bool isDefault: !!AudioService.sink && modelData.id === AudioService.sink.id
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
