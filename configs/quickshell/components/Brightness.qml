pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../components/ui"
import "../theme"
import "../services"

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
    implicitHeight: moduleRow.implicitHeight + (LayoutTheme.barWidgetHeight)
    width: implicitWidth
    height: implicitHeight
    Layout.fillWidth: true
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight
    radius: Shape.radiusNormal
    color: Colors.surface

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
            implicitWidth: LayoutTheme.barWidgetHeight
            implicitHeight: LayoutTheme.barWidgetHeight
            Layout.alignment: Qt.AlignVCenter
            radius: Shape.radiusNormal
            color: "transparent"

            Behavior on color {
                ColorAnimation {
                    duration: Animations.duration_hover
                    easing.type: Animations.easingStandard
                }
            }

            Text {
                anchors.centerIn: parent
                text: "󰃠"
                color: Colors.text
                font.pixelSize: Typography.icon
                font.family: Typography.iconFamily
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
            implicitWidth: LayoutTheme.barWidgetHeight
            implicitHeight: LayoutTheme.barWidgetHeight
            Layout.alignment: Qt.AlignVCenter
            radius: Shape.radiusNormal
            color: "transparent"

            Behavior on color {
                ColorAnimation {
                    duration: Animations.duration_hover
                    easing.type: Animations.easingStandard
                }
            }

            Text {
                anchors.centerIn: parent
                text: ""
                color: Colors.text
                font.pixelSize: Typography.icon
                font.family: Typography.iconFamily
            }
        }
    }

    onPanelScreenNameChanged: ensureMonitor()
    onDdcDisplayChanged: ensureMonitor()
    Component.onCompleted: ensureMonitor()
}
