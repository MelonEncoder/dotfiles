pragma ComponentBehavior: Bound

import QtQuick
import "../"

/*
  Slider

  Generic horizontal value slider: track + fill + thumb + drag handling.
  It has no opinion about what the value represents -- callers bind `value`
  for display and listen for `moved(percent)` to actually apply changes
  (e.g. via a debounced backend call). This makes it reusable for volume,
  brightness, or any other 0-100 control.
*/

Item {
    id: root

    property int value: 0 // 0-100, driven externally
    property int trackHeight: 14
    property int thumbDiameter: 22
    readonly property bool dragging: sliderMouse.pressed

    signal moved(int percent)

    implicitHeight: thumbDiameter

    function percentFromX(mouseX: real, trackWidth: real): int {
        var width = Math.max(1, trackWidth);
        var ratio = Math.max(0, Math.min(1, mouseX / width));
        return Math.round(ratio * 100);
    }

    Rectangle {
        id: sliderTrack
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: root.trackHeight
        radius: root.trackHeight / 2
        color: Theme.color_surface_hover

        Rectangle {
            id: sliderFill
            width: Math.max(radius * 2, Math.round(sliderTrack.width * root.value / 100))
            height: parent.height
            radius: parent.radius
            color: Theme.color_text

            Behavior on width {
                enabled: !root.dragging
                NumberAnimation {
                    duration: Animations.duration_fast
                    easing.type: Animations.easing_standard
                }
            }
        }
    }

    Rectangle {
        id: sliderThumb
        width: root.thumbDiameter
        height: root.thumbDiameter
        radius: root.thumbDiameter / 2
        color: Theme.color_text
        anchors.verticalCenter: sliderTrack.verticalCenter
        x: Math.max(0, Math.min(sliderTrack.width - width, Math.round(sliderTrack.width * root.value / 100) - width / 2))

        Behavior on x {
            enabled: !root.dragging
            NumberAnimation {
                duration: Animations.duration_fast
                easing.type: Animations.easing_standard
            }
        }

        Rectangle {
            anchors.centerIn: parent
            width: parent.width * 0.38
            height: parent.width * 0.38
            radius: width / 2
            color: Theme.color_surface
            opacity: 0.5
        }
    }

    MouseArea {
        id: sliderMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPressed: function (mouse) {
            root.moved(root.percentFromX(mouse.x, sliderTrack.width));
        }
        onPositionChanged: function (mouse) {
            if (!pressed)
                return;
            root.moved(root.percentFromX(mouse.x, sliderTrack.width));
        }
    }
}
