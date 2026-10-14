pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Networking

/*
  WifiService

  Wi-Fi state and actions on top of Quickshell.Networking: the first Wi-Fi
  device, its connected/available networks, the radio on/off switch, and
  scanning (enable it only while a network list is visible).
*/

Singleton {
    id: root

    readonly property var device: {
        const devs = Networking.devices.values;
        for (let i = 0; i < devs.length; i++) {
            if (devs[i].type === DeviceType.Wifi)
                return devs[i];
        }
        return null;
    }

    readonly property bool available: root.device !== null
    readonly property bool enabled: Networking.wifiEnabled
    readonly property bool connecting: !!root.device && root.device.state === ConnectionState.Connecting

    readonly property var connectedNetworks: root.device ? root.device.networks.values.filter(n => n.connected) : []
    readonly property var availableNetworks: root.device ? root.device.networks.values.filter(n => !n.connected) : []

    // One-line status for tiles/headers.
    readonly property string status: {
        if (!root.available)
            return Strings.tr(Strings.keys.unavailable);
        if (!root.enabled)
            return Strings.tr(Strings.keys.off);
        if (root.connecting)
            return Strings.tr(Strings.keys.connecting);
        if (root.connectedNetworks.length > 0)
            return root.networkName(root.connectedNetworks[0]);
        return Strings.tr(Strings.keys.none_connected);
    }

    function networkName(network: var): string {
        if (!network)
            return "Unknown Network";
        if (network.name && network.name.length > 0)
            return network.name;
        return "Hidden Network";
    }

    function setEnabled(on: bool): void {
        Networking.wifiEnabled = on;
    }

    function toggle(): void {
        root.setEnabled(!root.enabled);
    }

    function setScanning(on: bool): void {
        if (root.device)
            root.device.scannerEnabled = on;
    }
}
