import QtQuick
import QtQuick.Layouts
import "../../theme"

/*
  ToggleTile

  Quick-settings tile: one rounded chip split into a main toggle (icon +
  title + subtitle) and a dropdown button. The whole chip is filled with the
  accent color while `checked`; each half highlights on hover/press. The tile
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

Item {
    id: root

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property bool checked: false
    property bool expanded: false

    property int tileHeight: LayoutTheme.barWidgetHeight * 1.5

    readonly property color baseColor: root.checked ? Colors.accentPrimary : Colors.surface

    signal toggled()
    signal expandClicked()

    // Fill for one half of the chip; both halves share the same base color.
    function segmentColor(hovered: bool, pressed: bool, active: bool): color {
        if (pressed)
            return root.checked ? Qt.darker(root.baseColor, 1.15) : Colors.surfacePressed;
        if (hovered || active)
            return root.checked ? Qt.lighter(root.baseColor, 1.1) : Colors.surfaceHover;
        return root.baseColor;
    }

    implicitWidth: chipRow.implicitWidth
    implicitHeight: root.tileHeight

    RowLayout {
        id: chipRow
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: mainButton

            Layout.fillWidth: true
            Layout.fillHeight: true
            topLeftRadius: Shape.radiusNormal
            bottomLeftRadius: Shape.radiusNormal
            color: root.segmentColor(mainMouse.containsMouse, mainMouse.pressed, false)

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

        Rectangle {
            id: expandButton

            Layout.preferredWidth: LayoutTheme.barWidgetHeight + 4
            Layout.fillHeight: true
            topRightRadius: Shape.radiusNormal
            bottomRightRadius: Shape.radiusNormal
            color: root.segmentColor(expandMouse.containsMouse, expandMouse.pressed, root.expanded)

            Behavior on color {
                ColorAnimation {
                    duration: Animations.duration_hover
                    easing.type: Animations.easingStandard
                }
            }

            Text {
                anchors.centerIn: parent
                text: root.expanded ? "\uf077" : "\uf078"
                color: root.checked || root.expanded ? Colors.text : Colors.textSubtle
                font.pixelSize: Typography.sm
                font.family: Typography.iconFamily
            }

            MouseArea {
                id: expandMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.expandClicked()
            }
        }
    }

    // Short divider between the halves, drawn over the seam.
    Rectangle {
        x: expandButton.x
        anchors.verticalCenter: parent.verticalCenter
        width: 1
        height: Math.round(root.tileHeight * 0.5)
        color: root.checked ? Qt.rgba(1, 1, 1, 0.35) : Colors.borderSubtle
    }
}
