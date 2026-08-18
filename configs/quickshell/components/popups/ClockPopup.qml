pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../surfaces"
import "../../theme"
import "../../services"

BarPopupSurface {
    id: root

    required property Item anchorItem
    property int calYear: new Date().getFullYear()
    property int calMonth: new Date().getMonth() + 1
    readonly property int calendarWidth: CalendarTheme.cellWidth * 7

    function prevMonth(): void {
        if (root.calMonth === 1) {
            root.calMonth = 12;
            root.calYear -= 1;
        } else {
            root.calMonth -= 1;
        }
    }

    function nextMonth(): void {
        if (root.calMonth === 12) {
            root.calMonth = 1;
            root.calYear += 1;
        } else {
            root.calMonth += 1;
        }
    }

    function daysInMonth(year: int, month: int): int {
        return new Date(year, month, 0).getDate();
    }

    function firstWeekday(year: int, month: int): int {
        return new Date(year, month - 1, 1).getDay();
    }

    // Build flat array of cell objects for the calendar grid
    readonly property var calCells: {
        var cells = [];
        var offset = root.firstWeekday(root.calYear, root.calMonth);
        var total = root.daysInMonth(root.calYear, root.calMonth);
        var today = new Date();
        var todayDay = today.getDate();
        var todayMonth = today.getMonth() + 1;
        var todayYear = today.getFullYear();
        var cellCount = Math.ceil((offset + total) / 7) * 7;
        for (var i = 0; i < cellCount; i++) {
            var day = i - offset + 1;
            var isValid = i >= offset && day <= total;
            cells.push({
                day: isValid ? day : 0,
                isValid: isValid,
                isToday: isValid && day === todayDay && root.calMonth === todayMonth && root.calYear === todayYear,
                weekCol: i % 7
            });
        }
        return cells;
    }

    anchor.item: anchorItem
    anchor.rect.x: 0
    anchor.rect.y: LayoutTheme.barWidgetHeight + (LayoutTheme.barPadding * 2)
    text: Strings.tr(Strings.keys.calendar)
    contentSpacing: CalendarTheme.contentSpacing

    panelX: (root.width - panelWidth) / 2
    panelY: LayoutTheme.barWidgetHeight + (LayoutTheme.barPadding * 2)
    panelWidth: root.calendarWidth + (LayoutTheme.barWidgetPadding * 2)

    // Month navigation
    Item {
        width: parent.width
        height: CalendarTheme.navigationHeight

        Text {
            id: prevBtn
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: "‹"
            color: prevMonthMouse.containsMouse ? Colors.text : Colors.textSubtle
            font.pixelSize: Typography.title
            font.family: Typography.family
            leftPadding: 4

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
                onClicked: root.prevMonth()
            }
        }

        Text {
            anchors.centerIn: parent
            text: root.calYear + "年" + root.calMonth + "月"
            color: Colors.text
            font.pixelSize: Typography.size
            font.family: Typography.family
        }

        Text {
            id: nextBtn
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: "›"
            color: nextMonthMouse.containsMouse ? Colors.text : Colors.textSubtle
            font.pixelSize: Typography.title
            font.family: Typography.family
            rightPadding: 4

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
                onClicked: root.nextMonth()
            }
        }
    }

    // Day-of-week headers (日月火水木金土)
    Grid {
        columns: 7
        width: parent.width

        Repeater {
            model: ["日", "月", "火", "水", "木", "金", "土"]
            delegate: Text {
                required property string modelData
                required property int index
                width: CalendarTheme.cellWidth
                height: CalendarTheme.headerHeight
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: modelData
                // Sunday red, Saturday blue
                color: index === 0 ? CalendarTheme.sunday : (index === 6 ? CalendarTheme.saturday : Colors.textSubtle)
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
            model: root.calCells
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
                    text: parent.modelData.isValid ? parent.modelData.day.toString() : ""
                    color: {
                        if (!parent.modelData.isValid)
                            return "transparent";
                        if (parent.modelData.isToday)
                            return Colors.background;
                        if (parent.modelData.weekCol === 0)
                            return CalendarTheme.sunday;
                        if (parent.modelData.weekCol === 6)
                            return CalendarTheme.saturday;
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
