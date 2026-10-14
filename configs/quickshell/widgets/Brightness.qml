pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../components/ui"
import "../theme"
import "../services"

/*
  Brightness

  Control panel brightness row: an icon and a full-width Slider bound to
  BrightnessService. No backend/process logic lives here -- see
  BrightnessService.qml -- and no track/thumb/drag logic lives here either
  -- see Slider.qml.
*/

RowLayout {
    id: root

    Layout.fillWidth: true
    spacing: 8

    // Same footprint as Volume's mute button so the sliders line up.
    Item {
        Layout.alignment: Qt.AlignVCenter
        implicitWidth: LayoutTheme.barWidgetHeight
        implicitHeight: LayoutTheme.barWidgetHeight

        Text {
            anchors.centerIn: parent
            text: "󰃠"
            color: Colors.text
            font.pixelSize: Typography.icon
            font.family: Typography.iconFamily
        }
    }

    Slider {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter
        value: Math.round(BrightnessService.brightness * 100)
        onMoved: function (percent) {
            BrightnessService.setBrightness(percent / 100);
        }
    }
}
