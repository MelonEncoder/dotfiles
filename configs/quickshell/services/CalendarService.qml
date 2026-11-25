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

    readonly property string monthLabel: Languages.formatDate(new Date(root.year, root.month - 1, 1), Languages.keys.fmt_month_year)

    // Locale's first day of the week (0 = Sunday ... 6 = Saturday).
    readonly property int weekStart: Languages.qtLocale.firstDayOfWeek

    // Day numbers (0 = Sunday) in column order, starting at weekStart.
    readonly property var weekdayOrder: [0, 1, 2, 3, 4, 5, 6].map(i => (root.weekStart + i) % 7)

    // Column headers, e.g. 日 月 火 ... / S M T ...
    readonly property var weekdays: root.weekdayOrder.map(d => Languages.qtLocale.standaloneDayName(d, Locale.NarrowFormat))

    // Working days come from the locale; everything else is a weekend.
    function isWeekend(weekday: int): bool {
        const working = Languages.qtLocale.weekDays;
        for (let i = 0; i < working.length; i++) {
            if (working[i] === weekday)
                return false;
        }
        return true;
    }

    // One entry per grid cell, padded to whole weeks with the trailing days
    // of the previous month and leading days of the next (inMonth: false).
    readonly property var cells: {
        const offset = (root.firstWeekday(root.year, root.month) - root.weekStart + 7) % 7;
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
                weekCol: i % 7,
                isWeekend: root.isWeekend(root.weekdayOrder[i % 7])
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
