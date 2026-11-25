pragma Singleton

import Quickshell
import QtQuick

Singleton {
	id: root
	readonly property string time: {
		Qt.formatDateTime(clock.date, "HH:mm")
	}
	readonly property string date: {
		Languages.formatDate(clock.date, Languages.keys.fmt_date)
	}
	readonly property string fullDate: {
		Languages.formatDate(clock.date, Languages.keys.fmt_full_date)
	}

	SystemClock {
		id: clock
		precision: SystemClock.Minutes
	}
}
