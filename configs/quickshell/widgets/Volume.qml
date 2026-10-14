pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../theme"
import "../services/"
import "../components/ui"

/*
  Volume

  Control panel volume row: mute button, a full-width Slider, and a dropdown
  button that expands the output device list below the row.
*/

ColumnLayout {
    id: root

    property bool expanded: false

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

    Layout.fillWidth: true
    spacing: 6

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        LabelButton {
            Layout.alignment: Qt.AlignVCenter
            baseColor: "transparent"
            icon: !AudioService.sink ? "󰖁" : (AudioService.muted ? "󰝟" : "󰕾")
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
            iconSize: Typography.sm
            iconColor: root.expanded ? Colors.text : Colors.textSubtle
            onClicked: root.expanded = !root.expanded
        }
    }

    ExpandSection {
        expanded: root.expanded

        ListSection {
            title: Strings.tr(Strings.keys.output_devices)
            model: AudioService.audioSinks
            delegate: ListRow {
                id: deviceRow
                required property var modelData
                readonly property bool isDefault: !!AudioService.sink && modelData.id === AudioService.sink.id

                glyph: deviceRow.isDefault ? "\uf192" : "\uf10c"
                glyphColor: deviceRow.isDefault ? Colors.text : Colors.textSubtle
                text: modelData.description || modelData.nick || modelData.name || "Unknown"
                active: deviceRow.isDefault
                onClicked: root.setDefaultSink(deviceRow.modelData)
            }
        }
    }
}
