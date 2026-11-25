pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../components/ui"
import "../theme"
import "../services"

// Language list for the control panel's expandable language section.
// Selecting a row switches Languages.language (and persists it).
ColumnLayout {
    id: root

    spacing: 3

    ListSection {
        model: Languages.available
        delegate: ListRow {
            required property var modelData
            text: modelData.name
            glyph: modelData.code === Languages.language ? "󰄬" : ""
            glyphColor: Colors.accentPrimary
            active: modelData.code === Languages.language
            onClicked: Languages.setLanguage(modelData.code)
        }
    }
}
