pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../components/ui"
import "../services"

// Wi-Fi network list (connected + available) for the control panel's
// expandable Wi-Fi section. State lives in WifiService.
ColumnLayout {
    id: root

    spacing: 3

    ListSection {
        title: Strings.tr(Strings.keys.connected)
        model: WifiService.connectedNetworks
        emptyText: Strings.tr(Strings.keys.none_connected)
        delegate: ListRow {
            required property var modelData
            text: WifiService.networkName(modelData)
            onClicked: modelData.disconnect()
        }
    }

    ListSection {
        title: Strings.tr(Strings.keys.available)
        model: WifiService.availableNetworks
        emptyText: Strings.tr(Strings.keys.none_available)
        delegate: ListRow {
            required property var modelData
            text: WifiService.networkName(modelData)
            onClicked: modelData.connect()
        }
    }
}
