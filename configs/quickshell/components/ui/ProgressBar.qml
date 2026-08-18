import QtQuick
import "../"
import "../../theme"

/*
  ProgressBar

  Generic, non-interactive horizontal progress indicator: a track with a
  filled portion sized by `value / maximum`. Use this for read-only
  indicators like media playback position; use Slider.qml instead when the
  user needs to drag/set the value.
*/

Item {
    id: root

    property real value: 0
    property real maximum: 100
    property int barHeight: 3
    property color trackColor: Colors.surface
    property color fillColor: Colors.text
    property bool animated: true

    readonly property real ratio: root.maximum > 0 ? Math.max(0, Math.min(1, root.value / root.maximum)) : 0

    implicitHeight: root.barHeight

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: root.barHeight
        radius: height / 2
        color: root.trackColor

        Rectangle {
            id: fill
            width: Math.round(track.width * root.ratio)
            height: parent.height
            radius: parent.radius
            color: root.fillColor

            Behavior on width {
                enabled: root.animated
                NumberAnimation {
                    duration: Animations.duration_fast
                    easing.type: Animations.easingStandard
                }
            }
        }
    }
}
