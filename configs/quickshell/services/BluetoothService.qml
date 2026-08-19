pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {
    id: root

    property var adapter: Bluetooth.defaultAdapter
    property var devices: adapter ? adapter.devices.values : []

    readonly property bool available: adapter !== null
    readonly property bool enabled: adapter ? adapter.enabled : false
    readonly property bool discovering: adapter ? adapter.discovering : false

    function refresh(): void {
        if (!adapter) {
            return;
        }
        devices = adapter.devices.values
    }

    function getConnectedDevices(): var {
        var connected = [];

        for (var i = 0; i < devices.length; i++) {
            var device = devices[i];
            if (device && device.connected) {
                connected.push(device);
            }
        }

        return connected;
    }

    function getAvailableDevices(): var {
        var available = [];

        for (var i = 0; i < devices.length; i++) {
            var device = devices[i];

            if (!device || device.connected || device.blocked) {
                continue;
            }

            available.push(device);
        }

        return available;
    }

    function startDiscovery(): void {
        if (!adapter || !adapter.enabled || adapter.discovering) {
            return;
        }

        adapter.discovering = true
        refresh();
    }

    function stopDiscovery(): void {
        if (!adapter || !adapter.discovering) {
            return;
        }

        adapter.discovering = false;
        refresh();
    }

    function connect(device): void {
        if (device) {
            device.connect();
        }
    }

    function disconnect(device): void {
        if (device) {
            device.disconnect();
        }
    }

    Connections {
        target: root.adapter

        function onEnabledChanged(): void {
            root.refresh();
        }

        function onDiscoveringChanged(): void {
            root.refresh();
        }
    }

    Connections {
        target: root.adapter ? root.adapter.devices : null

        function onValuesChanged(): void {
            root.refresh();
        }
    }

    Timer {
        id: discoveryTimer

        interval: 10000
        repeat: false

        onTriggered: root.stopDiscovery()
    }

    function discover(): void {
        startDiscovery();
        discoveryTimer.restart();
    }
}
