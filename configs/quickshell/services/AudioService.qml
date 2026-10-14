pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

/*
  AudioService

  Tracks and sets the default sink (speaker) and source (microphone) volume
  and mute state via wpctl. Volumes are 0-1; writes are debounced and both
  are re-polled periodically so external changes are picked up. The output
  device list and default-sink switching come from Pipewire.
*/

Singleton {
    id: root

    property real volume: 0
    property real microphoneVolume: 0
    property bool muted: false
    property bool microphoneMuted: false
    property real pendingVolume: 0
    property real pendingMicrophoneVolume: 0

    readonly property var sink: Pipewire.defaultAudioSink

    readonly property var audioSinks: {
        const result = [];
        const nodes = Pipewire.nodes.values;
        for (let i = 0; i < nodes.length; i++) {
            const node = nodes[i];
            if (node.isSink && !node.isStream)
                result.push(node);
        }
        return result;
    }

    function setVolume(value: real): void {
        const clamped = Math.max(0, Math.min(1, value));
        pendingVolume = clamped;
        root.volume = clamped;
        sinkWriteTimer.restart();
    }

    function setMicrophoneVolume(value: real): void {
        const clamped = Math.max(0, Math.min(1, value));
        pendingMicrophoneVolume = clamped;
        root.microphoneVolume = clamped;
        sourceWriteTimer.restart();
    }

    function toggleMute(): void {
        root.muted = !root.muted;
        muteToggler.running = true;
    }

    function setDefaultSink(node: var): void {
        Pipewire.preferredDefaultAudioSink = node;
    }

    function readOutput(data: string, microphone: bool): void {
        const match = data.match(/Volume:\s+([0-9.]+)/);
        if (!match)
            return;

        if (microphone) {
            root.microphoneVolume = Number(match[1]);
            root.microphoneMuted = data.includes("MUTED");
        } else {
            root.volume = Number(match[1]);
            root.muted = data.includes("MUTED");
        }
    }

    Process {
        id: sinkReader
        running: true
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: data => root.readOutput(data, false)
        }
    }

    Process {
        id: sourceReader
        running: true
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SOURCE@"]
        stdout: SplitParser {
            onRead: data => root.readOutput(data, true)
        }
    }

    Process {
        id: sinkSetter
        onExited: sinkReader.running = true
    }

    Process {
        id: muteToggler
        command: ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
        onExited: sinkReader.running = true
    }

    Process {
        id: sourceSetter
        onExited: sourceReader.running = true
    }

    Timer {
        id: sinkWriteTimer
        interval: 40
        onTriggered: {
            if (sinkSetter.running) {
                restart();
                return;
            }
            sinkSetter.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", root.pendingVolume.toFixed(2)];
            sinkSetter.running = true;
        }
    }

    Timer {
        id: sourceWriteTimer
        interval: 40
        onTriggered: {
            if (sourceSetter.running) {
                restart();
                return;
            }
            sourceSetter.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SOURCE@", root.pendingMicrophoneVolume.toFixed(2)];
            sourceSetter.running = true;
        }
    }

    Timer {
        id: refreshTimer
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            if (!sinkReader.running && !sinkSetter.running)
                sinkReader.running = true;
            if (!sourceReader.running && !sourceSetter.running)
                sourceReader.running = true;
        }
    }

    // Re-read volume/mute right away when the default output changes.
    Connections {
        target: Pipewire
        function onDefaultAudioSinkChanged() {
            if (!sinkReader.running)
                sinkReader.running = true;
        }
    }
}
