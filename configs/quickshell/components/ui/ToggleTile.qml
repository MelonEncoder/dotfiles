import QtQuick
import QtQuick.Layouts
import "../../theme"

/*
  ToggleTile

  Quick-settings tile: a main toggle button (icon + title + subtitle, filled
  with the accent color while `checked`) next to a dropdown button. The tile
  only reports clicks -- the owner decides what toggling/expanding means,
  e.g. showing a full-width details section below the tile grid:

      ToggleTile {
          icon: "󰖩"
          title: "Wi-Fi"
          subtitle: WifiService.status
          checked: WifiService.enabled
          expanded: panel.openSection === "wifi"
          onToggled: WifiService.toggle()
          onExpandClicked: panel.toggleSection("wifi")
      }
*/

RowLayout {
    id: root

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property bool checked: false
    property bool expanded: false

    readonly property int tileHeight: LayoutTheme.barWidgetHeight * 1.5

    signal toggled()
    signal expandClicked()

    spacing: 2

    Rectangle {
        id: mainButton

        readonly property bool hovered: mainMouse.containsMouse
        readonly property bool pressed: mainMouse.pressed
        readonly property color baseColor: root.checked ? Colors.accentPrimary : Colors.surface

        Layout.fillWidth: true
        Layout.preferredHeight: root.tileHeight
        radius: Shape.radiusNormal
        color: {
            if (mainButton.pressed)
                return root.checked ? Qt.darker(mainButton.baseColor, 1.15) : Colors.surfacePressed;
            if (mainButton.hovered)
                return root.checked ? Qt.lighter(mainButton.baseColor, 1.1) : Colors.surfaceHover;
            return mainButton.baseColor;
        }

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
                rightMargin: 8
            }
            spacing: 10

            Text {
                text: root.icon
                color: Colors.text
                font.pixelSize: Typography.icon
                font.family: Typography.iconFamily
                Layout.alignment: Qt.AlignVCenter
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 1

                Text {
                    Layout.fillWidth: true
                    text: root.title
                    color: Colors.text
                    font.pixelSize: Typography.size
                    font.family: Typography.family
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    visible: root.subtitle.length > 0
                    text: root.subtitle
                    color: root.checked ? Colors.text : Colors.textSubtle
                    font.pixelSize: Typography.xs
                    font.family: Typography.family
                    elide: Text.ElideRight
                }
            }
        }

        MouseArea {
            id: mainMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.toggled()
        }
    }

    LabelButton {
        Layout.preferredWidth: LayoutTheme.barWidgetHeight
        Layout.preferredHeight: root.tileHeight
        active: root.expanded
        icon: root.expanded ? "" : ""
        iconSize: Typography.sm
        iconColor: root.expanded ? Colors.text : Colors.textSubtle
        onClicked: root.expandClicked()
    }
}
