
pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

/*
  VolumeService

  Central place for Pipewire default-sink state and actions. UI components
  bind to `sink` / `volume` / `muted` / `audioSinks` and call `setVolume`,
  `toggleMute`, `setDefaultSink` instead of touching Pipewire directly.

  Register this file as a singleton in your qmldir, e.g.:
      singleton VolumeService 1.0 VolumeService.qml
*/

Singleton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink

    // 0-150: Pipewire allows boosting volume above 100%.
    readonly property int volume: {
        if (!root.sink || !root.sink.audio)
            return 0;
        return Math.max(0, Math.min(150, Math.round(root.sink.audio.volume * 100)));
    }

    readonly property bool muted: !!root.sink && !!root.sink.audio && root.sink.audio.muted

    readonly property var audioSinks: {
        var result = [];
        var nodes = Pipewire.nodes.values;
        for (var i = 0; i < nodes.length; i++) {
            var node = nodes[i];
            if (node.isSink && !node.isStream)
                result.push(node);
        }
        return result;
    }

    function setVolume(percent: int): void {
        if (!root.sink || !root.sink.audio)
            return;
        var clamped = Math.max(0, Math.min(100, percent));
        root.sink.audio.volume = clamped / 100;
    }

    function toggleMute(): void {
        if (root.sink && root.sink.audio)
            root.sink.audio.muted = !root.sink.audio.muted;
    }

    function setDefaultSink(node: var): void {
        Pipewire.preferredDefaultAudioSink = node;
    }

    // Pipewire objects need to be tracked to keep receiving property updates.
    PwObjectTracker {
        id: sinkTracker
    }

    onSinkChanged: sinkTracker.objects = root.sink ? [root.sink] : []

    Component.onCompleted: {
        if (root.sink)
            sinkTracker.objects = [root.sink];
    }
}
