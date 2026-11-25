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
        title: Languages.tr(Languages.keys.connected)
        model: WifiService.connectedNetworks
        emptyText: Languages.tr(Languages.keys.none_connected)
        delegate: ListRow {
            required property var modelData
            text: WifiService.networkName(modelData)
            onClicked: modelData.disconnect()
        }
    }

    ListSection {
        title: Languages.tr(Languages.keys.available)
        model: WifiService.availableNetworks
        emptyText: Languages.tr(Languages.keys.none_available)
        delegate: ListRow {
            required property var modelData
            text: WifiService.networkName(modelData)
            onClicked: modelData.connect()
        }
    }
}
