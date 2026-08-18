import QtQuick
import QtQuick.Layouts
import "../../theme"

/*
  SquareButton

  Large square button for icon-grid menus (e.g. the power options menu).
  Shares LabelButton's hover/press/color-animation recipe, but lays out a
  themed icon image above a text label instead of a single-line icon+text
  row, and adds a keyboard-focus accent bar for grid navigation.
*/

Rectangle {
    id: root

    property string iconName: ""
    property string text: ""

    property int size: 150
    property int iconSize: 48
    property int labelSpacing: 8

    property bool focused: false // keyboard-navigated focus, distinct from active/pressed
    property color baseColor: Colors.surface
    property color accentColor: Colors.accentPrimary

    readonly property bool hasIcon: root.iconName.length > 0
    readonly property bool hasText: root.text.length > 0
    readonly property bool hovered: mouseArea.containsMouse
    readonly property bool pressed: mouseArea.pressed

    signal clicked()
    signal entered()

    implicitWidth: root.size
    implicitHeight: root.size
    radius: Shape.radiusNormal
    color: root.pressed ? Colors.surfacePressed : ((root.hovered || root.focused) ? root.accentColor : root.baseColor)
    clip: true

    Behavior on color {
        ColorAnimation {
            duration: Animations.duration_hover
            easing.type: Animations.easingStandard
        }
    }

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

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.entered()
        onClicked: root.clicked()
    }
}
