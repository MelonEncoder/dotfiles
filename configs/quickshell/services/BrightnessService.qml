pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

/*
  BrightnessService

  Tracks and sets display brightness. `brightness` is 0-1; writes are
  debounced. Uses brightnessctl when a backlight device exists, otherwise
  falls back to ddcutil (VCP 10) for external monitors. brightnessctl is
  re-polled periodically so external changes (e.g. brightness keys) are
  picked up; ddcutil is only read on startup since DDC/CI is slow.
*/

Singleton {
    id: root

    property real brightness: 0
    property real pendingBrightness: 0
    property string backend: "brightnessctl" // "brightnessctl" | "ddcutil"
    property int ddcMax: 100

    function setBrightness(value: real): void {
        const clamped = Math.max(0.01, Math.min(1, value));
        brightness = clamped;
        pendingBrightness = clamped;
        writeTimer.restart();
    }

    function readOutput(data: string): void {
        if (backend === "ddcutil") {
            // e.g. "VCP 10 C 50 100"
            const fields = data.trim().split(/\s+/);
            if (fields.length < 5 || fields[0] !== "VCP")
                return;

            const current = Number(fields[3]);
            const max = Number(fields[4]);
            if (!isNaN(current) && !isNaN(max) && max > 0) {
                ddcMax = max;
                brightness = current / max;
            }
            return;
        }

        const fields = data.trim().split(",");
        if (fields.length < 4)
            return;

        const percentage = Number(fields[3].replace("%", ""));
        if (!isNaN(percentage))
            brightness = percentage / 100;
    }

    Process {
        id: reader
        running: true
        command: root.backend === "ddcutil" ? ["ddcutil", "--brief", "getvcp", "10"] : ["brightnessctl", "--machine-readable", "--class=backlight", "info"]
        stdout: SplitParser {
            onRead: data => root.readOutput(data)
        }
        onExited: exitCode => {
            // No backlight device: switch to ddcutil and read again.
            if (exitCode !== 0 && root.backend === "brightnessctl") {
                root.backend = "ddcutil";
                reader.running = true;
            }
        }
    }

    Process {
        id: setter
        onExited: {
            if (root.backend === "brightnessctl")
                reader.running = true;
        }
    }

    Timer {
        id: writeTimer
        interval: 40
        onTriggered: {
            if (setter.running) {
                restart();
                return;
            }

            if (root.backend === "ddcutil")
                setter.command = ["ddcutil", "setvcp", "10", Math.round(root.pendingBrightness * root.ddcMax).toString()];
            else
                setter.command = ["brightnessctl", "--class=backlight", "set", Math.round(root.pendingBrightness * 100) + "%"];
            setter.running = true;
        }
    }

    Timer {
        interval: 2000
        running: root.backend === "brightnessctl"
        repeat: true
        onTriggered: {
            if (!reader.running && !setter.running)
                reader.running = true;
        }
    }
}
