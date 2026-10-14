pragma Singleton

import QtQuick
import Quickshell

/*
  CalendarService

  Calendar state for the clock popup: the month being viewed, month
  navigation, and the flat list of day cells for a 7-column grid. `today`
  follows the system clock so the highlight moves at midnight.
*/

Singleton {
    id: root

    readonly property date today: clock.date
    property int year: today.getFullYear()
    property int month: today.getMonth() + 1 // 1-12

    readonly property string monthLabel: root.year + "年" + root.month + "月"
    readonly property var weekdays: ["日", "月", "火", "水", "木", "金", "土"]

    // One entry per grid cell, padded to whole weeks with the trailing days
    // of the previous month and leading days of the next (inMonth: false).
    readonly property var cells: {
        const offset = root.firstWeekday(root.year, root.month);
        const total = root.daysInMonth(root.year, root.month);
        const isCurrentMonth = root.month === root.today.getMonth() + 1 && root.year === root.today.getFullYear();
        const todayDay = root.today.getDate();
        const cellCount = Math.ceil((offset + total) / 7) * 7;
        const result = [];
        for (let i = 0; i < cellCount; i++) {
            const day = i - offset + 1;
            const inMonth = day >= 1 && day <= total;
            result.push({
                // Date() rolls out-of-range days into the neighbouring month.
                day: new Date(root.year, root.month - 1, day).getDate(),
                inMonth: inMonth,
                isToday: inMonth && isCurrentMonth && day === todayDay,
                weekCol: i % 7
            });
        }
        return result;
    }

    function daysInMonth(year: int, month: int): int {
        return new Date(year, month, 0).getDate();
    }

    function firstWeekday(year: int, month: int): int {
        return new Date(year, month - 1, 1).getDay();
    }

    function prevMonth(): void {
        if (root.month === 1) {
            root.month = 12;
            root.year -= 1;
        } else {
            root.month -= 1;
        }
    }

    function nextMonth(): void {
        if (root.month === 12) {
            root.month = 1;
            root.year += 1;
        } else {
            root.month += 1;
        }
    }

    function goToToday(): void {
        root.year = root.today.getFullYear();
        root.month = root.today.getMonth() + 1;
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
