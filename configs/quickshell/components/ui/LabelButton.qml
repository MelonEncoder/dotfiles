import QtQuick
import "../../theme"

/*
  LabelButton

  Reusable icon (+ optional text) button built on HoverSurface, which
  supplies the hover/press color, animation, and click handling.

  Uses Item's built-in `enabled` property: set it to control both whether
  clicks fire and (via the default iconColor binding) whether the icon reads
  as disabled. `active` is for toggle/expanded-style buttons (e.g. a
  dropdown arrow) that should look "pressed" while a related state is true.
*/

HoverSurface {
    id: root

    // `icon` and `text` combine into a single centered label: icon-only
    // (the original use case) stays a fixed square via `size`; setting
    // `text` grows the button to hug icon + label + padding instead.
    property string icon: ""
    property string text: ""

    property int size: LayoutTheme.barWidgetHeight
    property int horizontalPadding: LayoutTheme.barWidgetPadding
    property int labelSpacing: 6

    property bool bordered: false
    property color iconColor: root.enabled ? Colors.text : Colors.textSubtle
    property color textColor: root.iconColor
    property real iconSize: Typography.icon
    property real textSize: Typography.size

    readonly property bool hasIcon: root.icon.length > 0
    readonly property bool hasText: root.text.length > 0

    implicitWidth: root.hasText ? label.implicitWidth + root.horizontalPadding * 2 : root.size
    implicitHeight: root.size
    activeColor: root.pressedColor
    border.width: root.bordered ? Shape.borderWidth : 0
    border.color: Colors.border

    Row {
        id: label
        anchors.centerIn: parent
        spacing: root.hasIcon && root.hasText ? root.labelSpacing : 0

        Text {
            visible: root.hasIcon
            text: root.icon
            color: root.iconColor
            font.pixelSize: root.iconSize
            font.family: Typography.iconFamily
        }

        Text {
            visible: root.hasText
            text: root.text
            color: root.textColor
            font.pixelSize: root.textSize
            font.family: Typography.family
        }
    }
}
