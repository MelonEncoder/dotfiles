import QtQuick
import QtQuick.Layouts
import "../../theme"

/*
  ListRow

  One row in a panel list (networks, devices, audio outputs, ...): optional
  icon-font glyph or themed icon image, then elided text, on a HoverSurface.
  Set `enabled: false` for a non-interactive placeholder row ("None
  connected"); its text dims automatically.

      ListRow {
          glyph: ""
          text: device.name
          active: device.isDefault
          onClicked: AudioService.setDefaultSink(device)
      }
*/

HoverSurface {
    id: root

    property string text: ""
    property string glyph: "" // icon-font glyph, e.g. ""
    property color glyphColor: Colors.text
    property string iconSource: "" // image URL, e.g. Quickshell.iconPath(...)
    property color textColor: root.enabled ? Colors.text : Colors.textSubtle

    Layout.fillWidth: true
    Layout.preferredHeight: LayoutTheme.barWidgetHeight
    baseColor: "transparent"

    RowLayout {
        anchors {
            fill: parent
            leftMargin: 10
            rightMargin: 10
        }
        spacing: 8

        Text {
            visible: root.glyph.length > 0
            text: root.glyph
            color: root.glyphColor
            font.pixelSize: Typography.sm
            font.family: Typography.iconFamily
            Layout.alignment: Qt.AlignVCenter
        }

        Image {
            visible: root.iconSource.length > 0
            source: root.iconSource
            fillMode: Image.PreserveAspectFit
            Layout.preferredWidth: Typography.icon
            Layout.preferredHeight: Typography.icon
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: root.text
            color: root.textColor
            font.pixelSize: Typography.size
            font.family: Typography.family
            elide: Text.ElideRight
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
