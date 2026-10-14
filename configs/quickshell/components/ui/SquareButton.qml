import QtQuick
import QtQuick.Layouts
import "../../theme"

/*
  SquareButton

  Large square button for icon-grid menus (e.g. the power options menu).
  Built on HoverSurface like LabelButton, but lays out a themed icon image
  above a text label, and highlights in the accent color on hover or
  keyboard focus (for grid navigation).
*/

HoverSurface {
    id: root

    property string iconName: ""
    property string text: ""

    property int size: 150
    property int iconSize: 48
    property int labelSpacing: 8

    property bool focused: false // keyboard-navigated focus, distinct from pressed
    property color accentColor: Colors.accentPrimary

    readonly property bool hasIcon: root.iconName.length > 0
    readonly property bool hasText: root.text.length > 0

    implicitWidth: root.size
    implicitHeight: root.size
    hoverColor: root.accentColor
    active: root.focused
    clip: true

    ColumnLayout {
        anchors.centerIn: parent
        spacing: root.labelSpacing

        Image {
            Layout.alignment: Qt.AlignHCenter
            visible: root.hasIcon
            source: root.hasIcon ? "image://icon/" + root.iconName : ""
            sourceSize.width: root.iconSize
            sourceSize.height: root.iconSize
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            visible: root.hasText
            text: root.text
            color: Colors.text
            font.pixelSize: Typography.size
            font.family: Typography.family
        }
    }
}
