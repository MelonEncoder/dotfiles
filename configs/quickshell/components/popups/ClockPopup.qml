pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import "../surfaces"
import "../../theme"
import "../../services"

BarPopupSurface {
    id: root

    readonly property int calendarWidth: CalendarTheme.cellWidth * 7

    anchor.rect.x: 0
    anchor.rect.y: LayoutTheme.barWidgetHeight + (LayoutTheme.barPadding * 2)
    text: Strings.tr(Strings.keys.calendar)
    contentSpacing: CalendarTheme.contentSpacing

    panelX: (root.width - panelWidth) / 2
    panelY: LayoutTheme.barWidgetHeight + (LayoutTheme.barPadding * 2)
    panelWidth: root.calendarWidth + (LayoutTheme.barWidgetPadding * 2)

    // Month navigation: [Month+Year, spacer, ‹, ›]
    RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: CalendarTheme.navigationHeight
        spacing: 4

        Text {
            Layout.alignment: Qt.AlignVCenter
            leftPadding: 4
            text: CalendarService.monthLabel
            color: Colors.text
            font.pixelSize: Typography.size
            font.family: Typography.family
        }

        Item {
            Layout.fillWidth: true
        }

        Text {
            id: prevBtn
            Layout.alignment: Qt.AlignVCenter
            leftPadding: 4
            rightPadding: 4
            text: "‹"
            color: prevMonthMouse.containsMouse ? Colors.text : Colors.textSubtle
            font.pixelSize: Typography.title
            font.family: Typography.family

            Behavior on color {
                ColorAnimation {
                    duration: Animations.duration_hover
                    easing.type: Animations.easingStandard
                }
            }

            MouseArea {
                id: prevMonthMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: CalendarService.prevMonth()
            }
        }

        Text {
            id: nextBtn
            Layout.alignment: Qt.AlignVCenter
            leftPadding: 4
            rightPadding: 4
            text: "›"
            color: nextMonthMouse.containsMouse ? Colors.text : Colors.textSubtle
            font.pixelSize: Typography.title
            font.family: Typography.family

            Behavior on color {
                ColorAnimation {
                    duration: Animations.duration_hover
                    easing.type: Animations.easingStandard
                }
            }

            MouseArea {
                id: nextMonthMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: CalendarService.nextMonth()
            }
        }
    }

    // Day-of-week headers (日月火水木金土)
    Grid {
        columns: 7
        width: parent.width

        Repeater {
            model: CalendarService.weekdays
            delegate: Text {
                required property string modelData
                required property int index
                width: CalendarTheme.cellWidth
                height: CalendarTheme.headerHeight
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: modelData
                // Weekends in the accent color
                color: index === 0 || index === 6 ? CalendarTheme.weekend : Colors.textSubtle
                font.pixelSize: Typography.xs
                font.family: Typography.family
            }
        }
    }

    Rectangle {
        width: parent.width
        height: 1
        color: Colors.borderSubtle
    }

    // Calendar day grid
    Grid {
        columns: 7
        width: parent.width
        bottomPadding: 2

        Repeater {
            model: CalendarService.cells
            delegate: Item {
                required property var modelData

                width: CalendarTheme.cellWidth
                height: CalendarTheme.cellHeight

                // Today highlight circle
                Rectangle {
                    anchors.centerIn: parent
                    width: CalendarTheme.todaySize
                    height: CalendarTheme.todaySize
                    radius: CalendarTheme.todaySize / 2
                    color: Colors.text
                    visible: parent.modelData.isToday
                }

                Text {
                    anchors.centerIn: parent
                    text: parent.modelData.day.toString()
                    color: {
                        if (!parent.modelData.inMonth)
                            return CalendarTheme.outsideMonth;
                        if (parent.modelData.isToday)
                            return Colors.background;
                        if (parent.modelData.weekCol === 0 || parent.modelData.weekCol === 6)
                            return CalendarTheme.weekend;
                        return Colors.text;
                    }
                    font.pixelSize: Typography.xs
                    font.family: Typography.family
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }
}
