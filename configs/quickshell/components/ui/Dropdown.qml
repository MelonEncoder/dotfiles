pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../../theme"

/*
  Dropdown

  Reusable bar-widget dropdown: a surface with a clickable header (icon +
  title + subtitle) that expands into an arbitrary body. Extracted from the
  Bluetooth and Wifi panels, which both hand-rolled this same
  header/expand-animation/body structure.

  Put the expandable content inside as regular children -- they land in a
  ColumnLayout, so use Layout.* attached properties same as before:

      Dropdown {
          icon: "󰂯"
          title: Strings.tr(Strings.keys.bluetooth)
          subtitle: BluetoothService.enabled ? "On" : "Off"
          onToggled: (expanded) => { if (expanded) BluetoothService.discover() }

          Text { Layout.fillWidth: true; text: "Connected" }
          Repeater { model: someDevices; delegate: someDelegate }
      }

  For a header that doesn't fit icon+title+subtitle (e.g. Volume's mute
  button + slider + toggle), supply `headerDelegate` instead. It's declared
  where the Dropdown is instantiated, so `root` inside it is the Dropdown
  itself -- read/write `root.expanded` directly instead of relying on
  `onToggled`:

      Dropdown {
          id: root
          headerDelegate: Component {
              Rectangle {
                  anchors.fill: parent
                  MouseArea { onClicked: root.expanded = !root.expanded }
              }
          }
      }
*/

Rectangle {
    id: root

    property bool expanded: false

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property bool showChevron: false

    // Overrides the built-in icon/title/subtitle header entirely when set.
    // See the file doc comment above for how to reach `root` from inside it.
    property Component headerDelegate: null

    default property alias content: expandedContent.data

    signal toggled(bool expanded)

    readonly property int sectionMargin: Math.round(LayoutTheme.barWidgetPadding / 2)
    readonly property int expandedContentHeight: expandedContent.implicitHeight

    implicitWidth: 280
    implicitHeight: frame.implicitHeight + (sectionMargin * 2)
    width: implicitWidth
    height: implicitHeight

    Layout.fillWidth: true
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight

    radius: Shape.radiusNormal
    color: Colors.surface

    Item {
        id: frame

        x: root.sectionMargin
        y: root.sectionMargin

        width: parent.width - (root.sectionMargin * 2)
        implicitHeight: menu.implicitHeight

        ColumnLayout {
            id: menu

            width: parent.width
            spacing: 4

            Loader {
                Layout.fillWidth: true
                Layout.preferredHeight: LayoutTheme.barWidgetHeight * 1.5

                sourceComponent: root.headerDelegate ? root.headerDelegate : defaultHeaderComponent
            }

            Item {
                visible: root.expanded || opacity > 0.01

                Layout.fillWidth: true
                Layout.preferredHeight: root.expanded ? root.expandedContentHeight : 0

                implicitHeight: root.expanded ? root.expandedContentHeight : 0

                opacity: root.expanded ? 1 : 0
                clip: true

                Behavior on Layout.preferredHeight {
                    NumberAnimation {
                        duration: Animations.dropdownSection
                        easing.type: Animations.easingEmphasized
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Animations.dropdownSection
                        easing.type: Animations.easingEmphasized
                    }
                }

                ColumnLayout {
                    id: expandedContent

                    anchors.left: parent.left
                    anchors.right: parent.right

                    spacing: 3
                }
            }
        }
    }

    Component {
        id: defaultHeaderComponent

        Rectangle {
            id: header

            anchors.fill: parent

            property bool hovered: headerMouse.containsMouse
            property bool pressed: headerMouse.pressed

            radius: Shape.radiusNormal
            color: pressed ? Colors.surfacePressed : Colors.surfaceHover

            Behavior on color {
                ColorAnimation {
                    duration: Animations.duration_hover
                    easing.type: Animations.easingStandard
                }
            }

            RowLayout {
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    leftMargin: 10
                    rightMargin: 10
                }

                spacing: 12

                Text {
                    visible: root.icon.length > 0
                    text: root.icon
                    color: Colors.text
                    font.pixelSize: Typography.icon
                    font.family: Typography.iconFamily
                    Layout.alignment: Qt.AlignVCenter
                }

                Column {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 1

                    Text {
                        text: root.title
                        color: Colors.text
                        font.pixelSize: Typography.size
                        font.family: Typography.family
                    }

                    Text {
                        visible: root.subtitle.length > 0
                        text: root.subtitle
                        color: Colors.textSubtle
                        font.pixelSize: Typography.size
                        font.family: Typography.family
                        elide: Text.ElideRight
                        width: Math.max(0, header.width - 60)
                    }
                }

                Text {
                    visible: root.showChevron
                    text: root.expanded ? "" : ""
                    color: Colors.textSubtle
                    font.pixelSize: Typography.xs
                    font.family: Typography.iconFamily
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            MouseArea {
                id: headerMouse

                anchors.fill: parent

                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    root.expanded = !root.expanded;
                    root.toggled(root.expanded);
                }
            }
        }
    }
}
