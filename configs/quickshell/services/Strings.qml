pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root
    property string language: "ja"

    // All translations keyed by string key, each holding a map of language
    // code -> translation. Add a new language code (e.g. "ko") to an entry
    // to support it for that string; missing entries fall back to English.
    readonly property var _all: ({
        // Popup window headers
        media:            { en: "Media",               ja: "メディア" },
        system:           { en: "System",               ja: "システム" },
        quick_settings:   { en: "Quick Settings",       ja: "クイック設定" },
        system_tray:      { en: "System Tray",          ja: "システムトレイ" },
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

        // Screenshot buttons
        fullscreen:       { en: "Fullscreen",            ja: "全画面" },
        region:           { en: "Region",                ja: "範囲選択" },

        // Volume
        output_devices:   { en: "Output Devices",        ja: "出力デバイス" },

        // Wi-Fi
        wifi:             { en: "Wi-Fi",                 ja: "Wi-Fi" },

        // Bluetooth
        bluetooth:        { en: "Bluetooth",             ja: "Bluetooth" },
        bt_on:            { en: "On",                    ja: "オン" },
        bt_off:           { en: "Off",                   ja: "オフ" },
        bt_unavailable:   { en: "Bluetooth unavailable", ja: "Bluetooth 使用不可" },
        bt_disabled:      { en: "Bluetooth disabled",    ja: "Bluetooth 無効" },
        scanning:         { en: "Scanning...",           ja: "スキャン中..." },

        // Power profiles
        power_profiles:   { en: "Power Profiles",        ja: "電源プロファイル" },

        // Shared status strings
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
        power_poweroff:   { en: "Shut Down",              ja: "シャットダウン" }
    })

    // Constant map of valid key names, derived from _all so there's a single
    // source of truth. QML/JS has no real interface or compile-time type
    // system, so this can't be statically enforced like a TypeScript union —
    // but it gives you named, autocomplete-able constants, and a typo like
    // Strings.keys.notifcations resolves to undefined instead of silently
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
            console.warn("Strings.tr: unknown key \"" + key + "\"");
            return key;
        }
        if (entry[root.language] !== undefined)
            return entry[root.language];
        if (entry.en !== undefined)
            return entry.en;
        console.warn("Strings.tr: key \"" + key + "\" has no translation for \"" + root.language + "\" or \"en\"");
        return key;
    }
}
