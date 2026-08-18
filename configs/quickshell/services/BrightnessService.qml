pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

/*
  BrightnessService

  Central place for brightness state and side effects (ddcutil / brightnessctl
  detection, probing current value, and applying changes). UI components no
  longer talk to `Process` directly -- they ask this service for a monitor
  handle and bind to its properties.

  Usage from a component:

      property var monitor: BrightnessService.monitorFor(screenName, ddcDisplay)
      ...
      Text { text: monitor.brightnessPercent + "%" }
      ...
      monitor.setBrightness(70)

  Register this file as a singleton in your qmldir, e.g.:
      singleton BrightnessService 1.0 BrightnessService.qml
*/

Singleton {
    id: root

    // screenName -> MonitorState instance
    property var _monitors: ({})

    // Emitted whenever any tracked monitor's brightness settles on a new
    // value. Handy for things like an OSD popup that isn't the slider itself.
    signal brightnessChanged(string screenName, int percent)

    function shellQuote(value: string): string {
        if (!value)
            return "''";
        return "'" + value.replace(/'/g, "'\"'\"'") + "'";
    }

    function clampPercent(value: int): int {
        return Math.max(0, Math.min(100, value));
    }

    // Returns the MonitorState for a screen, creating it (and kicking off
    // backend detection) on first use. Safe to call repeatedly/cheaply.
    function monitorFor(screenName: string, ddcDisplay: int): var {
        if (!screenName)
            screenName = "";

        var existing = root._monitors[screenName];
        if (existing) {
            if (ddcDisplay !== undefined && ddcDisplay > 0 && existing.ddcDisplay !== ddcDisplay)
                existing.ddcDisplay = ddcDisplay;
            return existing;
        }

        var state = monitorStateComponent.createObject(root, {
            "screenName": screenName,
            "ddcDisplay": ddcDisplay && ddcDisplay > 0 ? ddcDisplay : 1
        });

        state.brightnessPercentChanged.connect(function () {
            root.brightnessChanged(screenName, state.brightnessPercent);
        });

        root._monitors[screenName] = state;
        root._monitorsChanged();
        state.detectBackend();
        return state;
    }

    // Convenience accessors for callers that don't want to hold a live
    // reference to the monitor object.
    function brightnessPercent(screenName: string): int {
        var m = root._monitors[screenName];
        return m ? m.brightnessPercent : 50;
    }

    function setBrightness(screenName: string, percent: int, ddcDisplay: int): void {
        var m = root.monitorFor(screenName, ddcDisplay);
        m.setBrightness(percent);
    }

    // Internal: property change notifier for `_monitors` since QML doesn't
    // auto-emit for mutations of a plain JS object stored in a var property.
    signal _monitorsChanged()

    Component {
        id: monitorStateComponent
        MonitorState {}
    }
}

// Per-screen brightness state + the Process/Timer machinery to detect the
// right backend, read the current value, and (debounced) apply new values.
component MonitorState: QtObject {
    id: state

    property string screenName: ""
    property int ddcDisplay: 1

    property int brightnessPercent: 50
    property int brightnessMax: 100
    property int pendingBrightnessRaw: -1
    property int pendingBrightnessPercent: -1

    property string brightnessBackend: "ddcutil"
    property string brightnessCtlDevice: ""

    function setBrightness(percent: int): void {
        var next = BrightnessService.clampPercent(percent);
        if (next === state.brightnessPercent)
            return;
        state.brightnessPercent = next;
        var max = Math.max(1, state.brightnessMax);
        state.pendingBrightnessRaw = Math.round((next * max) / 100);
        state.pendingBrightnessPercent = next;
        applyTimer.restart();
    }

    function detectBackend(): void {
        detectProcess.exec(["sh", "-c", "name=" + BrightnessService.shellQuote(state.screenName) + "; " + "if printf '%s' \"$name\" | grep -Eq '^(eDP|LVDS|DSI)' ; then " + "for dev in /sys/class/backlight/*; do " + "[ -d \"$dev\" ] || continue; " + "printf 'brightnessctl\\t%s\\n' \"$(basename \"$dev\")\"; " + "exit 0; " + "done; " + "fi; " + "printf 'ddcutil\\t%s\\n' \"$name\""]);
    }

    function probe(): void {
        if (state.brightnessBackend === "brightnessctl" && state.brightnessCtlDevice.length > 0) {
            probeProcess.exec(["sh", "-c", "current=$(brightnessctl -d " + BrightnessService.shellQuote(state.brightnessCtlDevice) + " g 2>/dev/null); " + "max=$(brightnessctl -d " + BrightnessService.shellQuote(state.brightnessCtlDevice) + " m 2>/dev/null); " + "[ -n \"$current\" ] && [ -n \"$max\" ] && printf 'current value = %s\\nmax value = %s\\n' \"$current\" \"$max\" || true"]);
            return;
        }
        probeProcess.exec(["sh", "-c", "ddcutil --brief --display " + state.ddcDisplay + " getvcp 10 2>/dev/null || true"]);
    }

    Process {
        id: setProcess
    }

    Process {
        id: detectProcess
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                var raw = text.trim();
                if (raw.length === 0)
                    return;
                var parts = raw.split(/\t+/);
                var backend = parts.length > 0 ? parts[0].trim() : "";
                if (backend !== "brightnessctl" && backend !== "ddcutil")
                    backend = "ddcutil";
                state.brightnessBackend = backend;
                state.brightnessCtlDevice = backend === "brightnessctl" && parts.length > 1 ? parts[1].trim() : "";
                state.probe();
            }
        }
    }

    Process {
        id: probeProcess
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                var raw = text.trim();
                if (raw.length === 0)
                    return;
                var currentMatch = raw.match(/current value =\s*([0-9]+)/);
                var maxMatch = raw.match(/max value =\s*([0-9]+)/);
                if (!currentMatch || !maxMatch)
                    return;
                var current = parseInt(currentMatch[1]);
                var max = parseInt(maxMatch[1]);
                if (isNaN(current) || isNaN(max) || max <= 0)
                    return;
                state.brightnessMax = max;
                state.brightnessPercent = BrightnessService.clampPercent(Math.round((current * 100) / max));
            }
        }
    }

    Timer {
        id: applyTimer
        interval: 120
        running: false
        repeat: false
        onTriggered: {
            if (state.brightnessBackend === "brightnessctl") {
                if (state.pendingBrightnessPercent < 0 || state.brightnessCtlDevice.length === 0)
                    return;
                setProcess.exec(["sh", "-c", "brightnessctl -d " + BrightnessService.shellQuote(state.brightnessCtlDevice) + " set " + state.pendingBrightnessPercent + "% >/dev/null 2>&1 || true"]);
                return;
            }
            if (state.pendingBrightnessRaw < 0)
                return;
            setProcess.exec(["sh", "-c", "ddcutil --display " + state.ddcDisplay + " setvcp 10 " + state.pendingBrightnessRaw + " >/dev/null 2>&1 || true"]);
        }
    }
}
