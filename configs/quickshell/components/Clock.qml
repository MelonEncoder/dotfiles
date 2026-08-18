pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "../services"
import "../components/popups"
import "../theme"

Item {
    id: root
    property bool expanded: false
    property int calYear: new Date().getFullYear()
    property int calMonth: new Date().getMonth() + 1
    implicitWidth: widget.implicitWidth
    implicitHeight: LayoutTheme.barWidgetHeight

    function daysInMonth(year: int, month: int): int {
        return new Date(year, month, 0).getDate();
    }

    function firstWeekday(year: int, month: int): int {
        return new Date(year, month - 1, 1).getDay();
    }

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

    // ── Bar widget ──────────────────────────────────────────────────────────

    Rectangle {
        id: widget
        radius: Shape.radiusNormal
        color: widgetMouse.pressed ? Colors.surfacePressed : (widgetMouse.containsMouse ? Colors.surfaceHover : Colors.surface)
        border.width: Shape.borderWidth
        border.color: Colors.border
        implicitWidth: row.implicitWidth + (LayoutTheme.barWidgetPadding * 2)
        implicitHeight: LayoutTheme.barWidgetHeight

        Behavior on color {
            ColorAnimation {
                duration: Animations.duration_hover
                easing.type: Animations.easingStandard
            }
        }

        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: LayoutTheme.barWidgetPadding

            Text {
                text: ClockService.date
                color: Colors.textSubtle
                font.pixelSize: Typography.size
                font.family: Typography.family
            }

            Text {
                text: ClockService.time
                color: Colors.text
                font.pixelSize: Typography.size
                font.family: Typography.family
            }
        }

        MouseArea {
            id: widgetMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.calYear = new Date().getFullYear();
                root.calMonth = new Date().getMonth() + 1;
                root.expanded = !root.expanded;
            }
        }
    }

    // ── Calendar popup ──────────────────────────────────────────────────────

    HyprlandFocusGrab {
        active: root.expanded
        windows: [dropdown]
        onCleared: root.expanded = false
    }

    PopupWindow {
        id: dropdown
        anchor.item: root
        anchor.rect.x: 0
        anchor.rect.y: LayoutTheme.barWidgetHeight + (LayoutTheme.barPadding * 2)
        visible: root.expanded
        implicitWidth: dropdown.screen.width
        implicitHeight: dropdown.screen.height
        color: "transparent"

        // Backdrop — click outside or ESC to dismiss
        Backdrop {
            expanded: root.expanded
            onClose: root.expanded = false
        }

        Rectangle {
            id: popupPanel
            readonly property int contentWidth: CalendarTheme.cellWidth * 7

            x: (dropdown.width - width) / 2
            y: LayoutTheme.barWidgetHeight + (LayoutTheme.barPadding * 2)
            width: contentWidth + (LayoutTheme.barWidgetPadding * 2)
            height: popupContent.implicitHeight + (LayoutTheme.barWidgetPadding * 2)
            radius: Shape.radiusBackground
            color: Colors.background
            border.width: Shape.borderWidth
            focus: root.expanded
            Keys.onEscapePressed: root.expanded = false
            border.color: Colors.border
            opacity: root.expanded ? 1 : 0
            scale: root.expanded ? 1 : Animations.dropdownScaleClosed
            transformOrigin: Item.Top

            Behavior on opacity {
                NumberAnimation {
                    duration: Animations.dropdown
                    easing.type: Animations.easingEmphasized
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: Animations.dropdown
                    easing.type: Animations.easingEmphasized
                }
            }

            // Absorb clicks so backdrop doesn't fire through the panel
            MouseArea {
                anchors.fill: parent
            }

            Column {
                id: popupContent
                x: LayoutTheme.barWidgetPadding
                y: LayoutTheme.barWidgetPadding
                width: popupPanel.contentWidth
                spacing: CalendarTheme.contentSpacing

                // ── Section label ───────────────────────────────────────────

                Text {
                    text: Strings.tr(Strings.keys.calendar)
                    color: Colors.textSubtle
                    font.pixelSize: Typography.xs
                    font.family: Typography.family
                    font.letterSpacing: 1
                    leftPadding: 2
                    bottomPadding: 2
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Colors.borderSubtle
                }

                // ── Month navigation ────────────────────────────────────────

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

                // ── Day-of-week headers (日月火水木金土) ────────────────────

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

                // ── Calendar day grid ───────────────────────────────────────

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
        }
    }
}
