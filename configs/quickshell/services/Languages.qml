pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    property string language: "ja"

    // Selectable languages, shown in their own language (not translated) so
    // a user can always find theirs. Add an entry here when adding a code.
    readonly property var available: [
        { code: "en", name: "English" },
        { code: "ja", name: "日本語" }
    ]

    function languageName(code) {
        for (let i = 0; i < root.available.length; i++) {
            if (root.available[i].code === code)
                return root.available[i].name;
        }
        return code;
    }

    // Switches language and persists it; every tr()/qtLocale binding updates.
    function setLanguage(code) {
        if (code === root.language)
            return;
        root.language = code;
        stateFile.setText(code);
    }

    // Persisted selection — survives shell restarts
    FileView {
        id: stateFile
        path: Quickshell.statePath("language")
        preload: true
        printErrors: false

        onLoaded: {
            const saved = stateFile.text().trim();
            if (saved.length > 0)
                root.language = saved;
        }
    }

    // Qt locale matching `language`, for formatting dates, day/month names
    // and week layout. Add an entry here when adding a language code.
    readonly property var _qtLocaleNames: ({ en: "en_US", ja: "ja_JP" })
    readonly property var qtLocale: Qt.locale(root._qtLocaleNames[root.language] || "en_US")

    // Formats `date` with the current Qt locale using the pattern stored
    // under `formatKey` (e.g. keys.fmt_date), so names and order both localize.
    function formatDate(date, formatKey) {
        return root.qtLocale.toString(date, root.tr(formatKey));
    }

    // All translations keyed by string key, each holding a map of language
    // code -> translation. Add a new language code (e.g. "ko") to an entry
    // to support it for that string; missing entries fall back to English.
    readonly property var _all: ({
        // Popup window headers
        media:            { en: "Media",               ja: "メディア" },
        system:           { en: "System",               ja: "システム" },
        quick_settings:   { en: "Quick Settings",       ja: "クイック設定" },
        calendar:         { en: "Calendar",             ja: "カレンダー" },
        notifications:    { en: "Notifications",        ja: "通知" },
        wallpaper:        { en: "Wallpaper",             ja: "壁紙" },

        // Notification panel
        no_notifications: { en: "No notifications",     ja: "通知なし" },
        clear_all:        { en: "Clear all",            ja: "すべて削除" },

        // System info labels
        kernel:           { en: "Kernel",                ja: "カーネル" },
        version:          { en: "Version",               ja: "バージョン" },
        cpu:              { en: "CPU",                   ja: "CPU" },
        gpu:              { en: "GPU",                   ja: "GPU" },
        ram:              { en: "RAM",                   ja: "RAM" },
        storage:          { en: "Storage",                ja: "ストレージ" },

        // Volume
        output_devices:   { en: "Output Devices",        ja: "出力デバイス" },

        // Background apps (system tray)
        background_apps:  { en: "Background Apps",       ja: "バックグラウンドアプリ" },
        apps_running:     { en: "%1 running",            ja: "%1 個実行中" },

        // Wi-Fi
        wifi:             { en: "Wi-Fi",                 ja: "Wi-Fi" },

        // Bluetooth
        bluetooth:        { en: "Bluetooth",             ja: "Bluetooth" },
        bt_unavailable:   { en: "Bluetooth unavailable", ja: "Bluetooth 使用不可" },
        bt_disabled:      { en: "Bluetooth disabled",    ja: "Bluetooth 無効" },
        scanning:         { en: "Scanning...",           ja: "スキャン中..." },

        // Shared status strings
        on:               { en: "On",                    ja: "オン" },
        off:              { en: "Off",                   ja: "オフ" },
        unavailable:      { en: "Unavailable",           ja: "使用不可" },
        connecting:       { en: "Connecting...",         ja: "接続中..." },
        connected:        { en: "Connected",             ja: "接続済み" },
        available:        { en: "Available",             ja: "利用可能" },
        none_connected:   { en: "None connected",        ja: "未接続" },
        none_available:   { en: "None available",        ja: "なし" },
        loading:          { en: "Loading...",            ja: "読み込み中..." },

        // Media fallback
        no_media:         { en: "No media",              ja: "メディアなし" },

        // Power actions
        power_lock:       { en: "Lock Screen",           ja: "ロック画面" },
        power_logout:     { en: "Log Out",               ja: "ログアウト" },
        power_suspend:    { en: "Sleep",                 ja: "スリープ" },
        power_reboot:     { en: "Restart",                ja: "再起動" },
        power_poweroff:   { en: "Shut Down",              ja: "シャットダウン" },

        // Language picker
        language_label:   { en: "Language",              ja: "言語" },

        // Lock screen
        input_password:   { en: "Input Password...",     ja: "パスワードを入力..." },

        // Date format patterns (Qt date format syntax), used with qtLocale
        fmt_date:         { en: "MMM d",                 ja: "M月d日" },
        fmt_full_date:    { en: "dddd, MMMM d, yyyy",    ja: "yyyy年M月d日 dddd" },
        fmt_month_year:   { en: "MMMM yyyy",             ja: "yyyy年M月" }
    })

    // Constant map of valid key names, derived from _all so there's a single
    // source of truth. QML/JS has no real interface or compile-time type
    // system, so this can't be statically enforced like a TypeScript union —
    // but it gives you named, autocomplete-able constants, and a typo like
    // Languages.keys.notifcations resolves to undefined instead of silently
    // compiling as a valid-looking string literal.
    readonly property var keys: (function() {
        var map = {};
        for (var k in root._all)
            map[k] = k;
        return map;
    })()

    // Looks up `key`, returning the translation for the current language,
    // falling back to English if that language is missing the entry, and
    // finally to the key itself if the entry doesn't exist at all (so a typo
    // shows up as visible text, not "undefined").
    // Still reactive: since this reads root.language and root._all, any
    // binding that calls tr("...") re-evaluates automatically on language change.
    function tr(key) {
        var entry = root._all[key];
        if (entry === undefined) {
            console.warn("Languages.tr: unknown key \"" + key + "\"");
            return key;
        }
        if (entry[root.language] !== undefined)
            return entry[root.language];
        if (entry.en !== undefined)
            return entry.en;
        console.warn("Languages.tr: key \"" + key + "\" has no translation for \"" + root.language + "\" or \"en\"");
        return key;
    }
}
