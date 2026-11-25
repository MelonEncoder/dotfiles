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
        { code: "ja", name: "日本語" },
        { code: "es", name: "Español" },
        { code: "ru", name: "Русский" }
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
    readonly property var _qtLocaleNames: ({ en: "en_US", ja: "ja_JP", es: "es_ES", ru: "ru_RU" })
    readonly property var qtLocale: Qt.locale(root._qtLocaleNames[root.language] || "en_US")

    // Formats `date` with the current Qt locale using the pattern stored
    // under `formatKey` (e.g. keys.fmt_date), so names and order both localize.
    // Extra token: LLLL = standalone month name (nominative, e.g. Russian
    // "ноябрь" rather than "ноября"), for patterns with no day number. Qt's
    // MMMM always uses the form that follows a day.
    function formatDate(date, formatKey) {
        const month = root.qtLocale.standaloneMonthName(date.getMonth());
        const pattern = root.tr(formatKey).replace(/LLLL/g, "'" + month + "'");
        return root.qtLocale.toString(date, pattern);
    }

    // All translations keyed by string key, each holding a map of language
    // code -> translation. Add a new language code (e.g. "ko") to an entry
    // to support it for that string; missing entries fall back to English.
    readonly property var _all: ({
        // Popup window headers
        media:            { en: "Media",               ja: "メディア", es: "Multimedia", ru: "Медиа" },
        system:           { en: "System",               ja: "システム", es: "Sistema", ru: "Система" },
        quick_settings:   { en: "Quick Settings",       ja: "クイック設定", es: "Ajustes rápidos", ru: "Быстрые настройки" },
        calendar:         { en: "Calendar",             ja: "カレンダー", es: "Calendario", ru: "Календарь" },
        notifications:    { en: "Notifications",        ja: "通知", es: "Notificaciones", ru: "Уведомления" },
        wallpaper:        { en: "Wallpaper",             ja: "壁紙", es: "Fondo de pantalla", ru: "Обои" },

        // Notification panel
        no_notifications: { en: "No notifications",     ja: "通知なし", es: "No hay notificaciones", ru: "Нет уведомлений" },
        clear_all:        { en: "Clear all",            ja: "すべて削除", es: "Borrar todo", ru: "Очистить всё" },

        // System info labels
        kernel:           { en: "Kernel",                ja: "カーネル", es: "Kernel", ru: "Ядро" },
        version:          { en: "Version",               ja: "バージョン", es: "Versión", ru: "Версия" },
        cpu:              { en: "CPU",                   ja: "CPU", es: "CPU", ru: "ЦП" },
        gpu:              { en: "GPU",                   ja: "GPU", es: "GPU", ru: "ГП" },
        ram:              { en: "RAM",                   ja: "RAM", es: "RAM", ru: "ОЗУ" },
        storage:          { en: "Storage",                ja: "ストレージ", es: "Almacenamiento", ru: "Хранилище" },

        // Volume
        output_devices:   { en: "Output Devices",        ja: "出力デバイス", es: "Dispositivos de salida", ru: "Устройства вывода" },

        // Background apps (system tray)
        background_apps:  { en: "Background Apps",       ja: "バックグラウンドアプリ", es: "Apps en segundo plano", ru: "Фоновые приложения" },
        apps_running:     { en: "%1 running",            ja: "%1 個実行中", es: "%1 en ejecución", ru: "Запущено: %1" },

        // Wi-Fi
        wifi:             { en: "Wi-Fi",                 ja: "Wi-Fi", es: "Wi-Fi", ru: "Wi-Fi" },

        // Bluetooth
        bluetooth:        { en: "Bluetooth",             ja: "Bluetooth", es: "Bluetooth", ru: "Bluetooth" },
        bt_unavailable:   { en: "Bluetooth unavailable", ja: "Bluetooth 使用不可", es: "Bluetooth no disponible", ru: "Bluetooth недоступен" },
        bt_disabled:      { en: "Bluetooth disabled",    ja: "Bluetooth 無効", es: "Bluetooth desactivado", ru: "Bluetooth отключён" },
        scanning:         { en: "Scanning...",           ja: "スキャン中...", es: "Buscando...", ru: "Поиск..." },

        // Shared status strings
        on:               { en: "On",                    ja: "オン", es: "Activado", ru: "Вкл." },
        off:              { en: "Off",                   ja: "オフ", es: "Desactivado", ru: "Выкл." },
        unavailable:      { en: "Unavailable",           ja: "使用不可", es: "No disponible", ru: "Недоступно" },
        connecting:       { en: "Connecting...",         ja: "接続中...", es: "Conectando...", ru: "Подключение..." },
        connected:        { en: "Connected",             ja: "接続済み", es: "Conectados", ru: "Подключённые" },
        available:        { en: "Available",             ja: "利用可能", es: "Disponibles", ru: "Доступные" },
        none_connected:   { en: "None connected",        ja: "未接続", es: "Ninguno conectado", ru: "Нет подключений" },
        none_available:   { en: "None available",        ja: "なし", es: "Ninguno disponible", ru: "Нет доступных" },
        loading:          { en: "Loading...",            ja: "読み込み中...", es: "Cargando...", ru: "Загрузка..." },

        // Media fallback
        no_media:         { en: "No media",              ja: "メディアなし", es: "Sin contenido multimedia", ru: "Нет медиа" },

        // Power actions
        power_lock:       { en: "Lock Screen",           ja: "ロック画面", es: "Bloquear pantalla", ru: "Заблокировать" },
        power_logout:     { en: "Log Out",               ja: "ログアウト", es: "Cerrar sesión", ru: "Выйти" },
        power_suspend:    { en: "Sleep",                 ja: "スリープ", es: "Suspender", ru: "Спящий режим" },
        power_reboot:     { en: "Restart",                ja: "再起動", es: "Reiniciar", ru: "Перезагрузить" },
        power_poweroff:   { en: "Shut Down",              ja: "シャットダウン", es: "Apagar", ru: "Выключить" },

        // Language picker
        language_label:   { en: "Language",              ja: "言語", es: "Idioma", ru: "Язык" },

        // Lock screen
        input_password:   { en: "Input Password...",     ja: "パスワードを入力...", es: "Introduce la contraseña...", ru: "Введите пароль..." },

        // Date format patterns (Qt date format syntax), used with qtLocale
        fmt_date:         { en: "MMM d",                 ja: "M月d日", es: "d MMM", ru: "d MMM" },
        fmt_full_date:    { en: "dddd, MMMM d, yyyy",    ja: "yyyy年M月d日 dddd", es: "dddd, d 'de' MMMM 'de' yyyy", ru: "dddd, d MMMM yyyy 'г.'" },
        fmt_month_year:   { en: "MMMM yyyy",             ja: "yyyy年M月", es: "LLLL 'de' yyyy", ru: "LLLL yyyy" }
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
