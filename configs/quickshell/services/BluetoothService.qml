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
                connected.push(devices);
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
    }

    function startDiscovery(): void {
        if (!adapter || !adapter.enable || adapter.discovering) {
            return;
        }

        adapter.discovering = true
        refresh();
    }

    function stopDiscovery(): void {
        if (!adapter || !adapter.discovering) {
            return;
        }

        adapter.discoving = false;
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

        function onDevicesChanged(): void {
            root.refresh();
        }

        function onEnabledChanged(): void {
            root.refresh();
        }

        function onDiscoveryChanged(): void {
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
