import QtQuick
import "../../theme"

/*
  HoverSurface

  Base for anything clickable: a rounded Rectangle whose color follows
  hover/press (with the shared color animation) and a MouseArea filling it.
  Buttons, rows, and tiles build on this instead of hand-rolling the same
  Rectangle + MouseArea + color ternary + Behavior.

  Color precedence: pressed > active > hovered > base. `active` is for
  toggled/expanded/focused looks that should hold while the pointer is away.

      HoverSurface {
          baseColor: "transparent"
          active: root.expanded
          onClicked: root.expanded = !root.expanded

          Text { anchors.centerIn: parent; text: "..." }
      }

  Uses a conditional binding + Behavior (not States) on purpose: Qt
  recommends this for hover-style colors, since a Behavior driven by an
  interrupted State change can settle on the wrong color.
*/

Rectangle {
    id: root

    property color baseColor: Colors.surface
    property color hoverColor: Colors.surfaceHover
    property color pressedColor: Colors.surfacePressed
    property color activeColor: root.hoverColor
    property bool active: false

    property alias hoverEnabled: mouseArea.hoverEnabled
    property alias acceptedButtons: mouseArea.acceptedButtons

    readonly property bool hovered: mouseArea.containsMouse
    readonly property bool pressed: mouseArea.pressed

    signal clicked(var mouse)
    signal entered()

    radius: Shape.radiusNormal
    color: {
        if (root.pressed)
            return root.pressedColor;
        if (root.active)
            return root.activeColor;
        if (root.hovered)
            return root.hoverColor;
        return root.baseColor;
    }

    Behavior on color {
        ColorAnimation {
            duration: Animations.duration_hover
            easing.type: Animations.easingStandard
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: mouse => root.clicked(mouse)
        onEntered: root.entered()
    }
}
