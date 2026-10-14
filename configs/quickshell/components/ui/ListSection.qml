import QtQuick
import QtQuick.Layouts
import "../../theme"

/*
  ListSection

  A titled group of rows: a subtle heading, one `delegate` instance per
  `model` entry, and a dimmed `emptyText` row when the model is empty.
  `delegate` is a Component -- a template the Repeater stamps out per entry
  -- so callers just declare what a row looks like:

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
*/

ColumnLayout {
    id: root

    property string title: ""
    property var model: []
    property Component delegate: null
    property string emptyText: ""

    readonly property int count: rows.count

    Layout.fillWidth: true
    spacing: 3

    Text {
        visible: root.title.length > 0
        text: root.title
        color: Colors.textSubtle
        font.pixelSize: Typography.size
        font.family: Typography.family
        Layout.fillWidth: true
        Layout.topMargin: 4
    }

    Repeater {
        id: rows
        model: root.model
        delegate: root.delegate
    }

    ListRow {
        visible: rows.count === 0 && root.emptyText.length > 0
        enabled: false
        text: root.emptyText
    }
}
