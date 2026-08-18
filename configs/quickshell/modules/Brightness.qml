pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../components/ui"

/*
  BrightnessModule

  Bar widget: icon slots framing a generic Slider, bound to
  BrightnessService. No backend/process logic lives here -- see
  BrightnessService.qml -- and no track/thumb/drag logic lives here either
  -- see Slider.qml.
*/

Rectangle {
    id: root
    property string panelScreenName: ""
    property int ddcDisplay: 1

    // Live handle into the service; re-resolved whenever the target screen
    // (or its ddc display index) changes.
    property var monitor: null
    readonly property int brightnessPercent: monitor ? monitor.brightnessPercent : 50

    function ensureMonitor(): void {
        if (!root.panelScreenName) {
            root.monitor = null;
            return;
        }
        root.monitor = BrightnessService.monitorFor(root.panelScreenName, root.ddcDisplay);
    }

    implicitWidth: 280
    implicitHeight: moduleRow.implicitHeight + (Theme.bar_widget_height)
    width: implicitWidth
    height: implicitHeight
    Layout.fillWidth: true
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight
    radius: Theme.radius_normal
    color: Theme.color_surface

    RowLayout {
        id: moduleRow
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: 10
            rightMargin: 10
        }
        spacing: 10

        Rectangle {
            id: leftSlot
            implicitWidth: Theme.bar_widget_height
            implicitHeight: Theme.bar_widget_height
            Layout.alignment: Qt.AlignVCenter
            radius: Theme.radius_normal
            color: "transparent"

            Behavior on color {
                ColorAnimation {
                    duration: Animations.duration_hover
                    easing.type: Animations.easing_standard
                }
            }

            Text {
                anchors.centerIn: parent
                text: "󰃠"
                color: Theme.color_text
                font.pixelSize: Theme.font_size_icon
                font.family: Theme.font_family_icon
            }
        }

        Slider {
            id: brightnessSlider
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            value: root.brightnessPercent
            onMoved: function (percent) {
                if (root.monitor)
                    root.monitor.setBrightness(percent);
            }
        }

        Rectangle {
            id: rightSlot
            implicitWidth: Theme.bar_widget_height
            implicitHeight: Theme.bar_widget_height
            Layout.alignment: Qt.AlignVCenter
            radius: Theme.radius_normal
            color: "transparent"

            Behavior on color {
                ColorAnimation {
                    duration: Animations.duration_hover
                    easing.type: Animations.easing_standard
                }
            }

            Text {
                anchors.centerIn: parent
                text: ""
                color: Theme.color_text
                font.pixelSize: Theme.font_size_icon
                font.family: Theme.font_family_icon
            }
        }
    }

    onPanelScreenNameChanged: ensureMonitor()
    onDdcDisplayChanged: ensureMonitor()
    Component.onCompleted: ensureMonitor()
}
