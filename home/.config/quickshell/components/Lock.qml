pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pam
import Quickshell.Hyprland
import QtQuick
import "."
import "../services" as Services

Scope {
    id: root

    property bool locked: false
    property bool authenticating: false
    property bool failedAttempt: false
    property string statusText: ""
    property string submittedSecret: ""
    readonly property string currentUser: (Quickshell.env("USER") || "") + ""

    function activateLock(): void {
        if (root.locked)
            return;
        root.locked = true;
        root.authenticating = false;
        root.failedAttempt = false;
        root.statusText = "";
        root.submittedSecret = "";
    }

    function resetPrompt(): void {
        root.authenticating = false;
        root.submittedSecret = "";
    }

    function submitSecret(secret: string): void {
        var value = (secret || "") + "";
        if (!root.locked || root.authenticating)
            return;
        if (value.length === 0) {
            root.statusText = "Enter your password";
            root.failedAttempt = true;
            return;
        }

        root.authenticating = true;
        root.failedAttempt = false;
        root.statusText = "Checking password...";
        root.submittedSecret = value;

        if (!pam.start()) {
            root.authenticating = false;
            root.submittedSecret = "";
            root.failedAttempt = true;
            root.statusText = "Unable to start PAM";
        }
    }

    function finishUnlock(): void {
        root.locked = false;
        root.authenticating = false;
        root.failedAttempt = false;
        root.statusText = "";
        root.submittedSecret = "";
        sessionLock.unlock();
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "lock-screen"
        description: "Lock the current session"
        triggerDescription: "SUPER+L"
        onPressed: root.activateLock()
    }

    IpcHandler {
        target: "lock"

        function lock(): void {
            root.activateLock();
        }
    }

    Process {
        id: suspendProcess
        command: ["systemctl", "suspend"]
    }

    Process {
        id: sleepProcess
        command: ["systemctl", "hibernate"]
    }

    Process {
        id: shutdownProcess
        command: ["systemctl", "poweroff"]
    }

    Process {
        id: rebootProcess
        command: ["systemctl", "reboot"]
    }

    WlSessionLock {
        id: sessionLock
        locked: root.locked
        surface: lockSurface
    }

    PamContext {
        id: pam
        config: "quickshell"
        user: root.currentUser

        onPamMessage: {
            if (!root.authenticating)
                return;
            if (message && message.length > 0) {
                root.statusText = message;
                root.failedAttempt = messageIsError;
            }

            if (responseRequired) {
                respond(root.submittedSecret);
                root.submittedSecret = "";
            }
        }

        onCompleted: result => {
            root.authenticating = false;
            root.submittedSecret = "";

            if (result === PamResult.Success) {
                root.finishUnlock();
                return;
            }

            root.failedAttempt = true;
            root.statusText = result === PamResult.MaxTries ? "Too many failed attempts" : "Incorrect password";
        }

        onError: error => {
            root.authenticating = false;
            root.submittedSecret = "";
            root.failedAttempt = true;
            root.statusText = PamError.toString(error);
        }
    }

    Component {
        id: lockSurface

        WlSessionLockSurface {
            id: surface
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                color: Theme.lock_base

                Rectangle {
                    anchors.fill: parent
                    color: Theme.lock_scrim
                }

                FocusScope {
                    id: focusRoot
                    anchors.fill: parent
                    focus: true

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.ArrowCursor
                        onPressed: passwordInput.forceActiveFocus()
                    }

                    Column {
                        id: lockColumn
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: 0
                        width: Math.min(parent.width - (Theme.lock_screen_margin * 2), Theme.lock_column_width)
                        spacing: Theme.lock_column_spacing

                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 10

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "󰌾"
                                color: Theme.color_text
                                font.family: Theme.font_family_icon
                                font.pixelSize: Theme.lock_date_font_size + 6
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Locked"
                                color: Theme.color_text
                                font.family: Theme.lock_body_font_family
                                font.pixelSize: Theme.lock_date_font_size + 6
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: Theme.lock_header_spacing

                            Item {
                                width: parent.width
                                height: timeText.implicitHeight

                                Text {
                                    id: timeText
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: Services.ClockService.time
                                    horizontalAlignment: Text.AlignHCenter
                                    font.family: Theme.lock_time_font_family
                                    font.pixelSize: Theme.lock_time_font_size
                                    font.bold: true

                                    SequentialAnimation on color {
                                        loops: Animation.Infinite
                                        ColorAnimation { from: "#ff6b6b"; to: "#ffb347"; duration: 700 }
                                        ColorAnimation { to: "#ffff66"; duration: 700 }
                                        ColorAnimation { to: "#6bff6b"; duration: 700 }
                                        ColorAnimation { to: "#6bd5ff"; duration: 700 }
                                        ColorAnimation { to: "#8b5cf6"; duration: 700 }
                                        ColorAnimation { to: "#ff6bff"; duration: 700 }
                                        ColorAnimation { to: "#ff6b6b"; duration: 700 }
                                    }
                                }
                            }

                            Item {
                                width: parent.width
                                height: dateText.implicitHeight

                                Text {
                                    id: dateText
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: Services.ClockService.fullDate
                                    horizontalAlignment: Text.AlignHCenter
                                    color: Theme.color_text
                                    font.family: Theme.lock_body_font_family
                                    font.pixelSize: Theme.lock_date_font_size
                                }
                            }
                        }

                        Item {
                            width: parent.width
                            height: Theme.lock_input_height

                            Rectangle {
                                id: inputFrame
                                property color frameBorderColor: root.failedAttempt ? Theme.lock_error : Theme.color_accent_primary

                                anchors.fill: parent
                                radius: Theme.lock_input_radius
                                color: Theme.color_text
                                border.width: Theme.lock_input_border_width
                                border.color: frameBorderColor

                                Behavior on frameBorderColor {
                                    ColorAnimation {
                                        duration: Animations.duration_normal
                                        easing.type: Animations.easing_standard
                                    }
                                }

                                TextInput {
                                    id: passwordInput
                                    anchors.fill: parent
                                    anchors.leftMargin: Theme.lock_input_padding
                                    anchors.rightMargin: Theme.lock_input_padding
                                    verticalAlignment: TextInput.AlignVCenter
                                    color: Theme.color_background
                                    font.family: Theme.lock_body_font_family
                                    font.pixelSize: Theme.lock_input_font_size
                                    echoMode: TextInput.Password
                                    passwordCharacter: "•"
                                    selectByMouse: false
                                    focus: true
                                    enabled: root.locked && !root.authenticating
                                    inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase

                                    onAccepted: root.submitSecret(text)
                                    onTextEdited: {
                                        if (root.failedAttempt)
                                            root.failedAttempt = false;
                                        if (root.statusText === "Incorrect password" || root.statusText === "Too many failed attempts" || root.statusText === "Enter your password") {
                                            root.statusText = "";
                                        }
                                    }

                                    Keys.onEscapePressed: {
                                        text = "";
                                        root.failedAttempt = false;
                                        root.statusText = "";
                                    }
                                }

                                Text {
                                    anchors.fill: parent
                                    anchors.leftMargin: Theme.lock_input_padding
                                    anchors.rightMargin: Theme.lock_input_padding
                                    verticalAlignment: Text.AlignVCenter
                                    text: passwordInput.text.length === 0 ? "Input Password..." : ""
                                    color: Theme.lock_placeholder
                                    font.family: Theme.lock_body_font_family
                                    font.pixelSize: Theme.lock_input_font_size
                                    font.italic: true
                                }
                            }


                        }

                        Text {
                            width: parent.width
                            height: Theme.lock_status_height
                            text: root.authenticating ? "Checking password..." : root.statusText
                            visible: text.length > 0
                            horizontalAlignment: Text.AlignHCenter
                            color: root.failedAttempt ? Theme.lock_error : Theme.color_text
                            font.family: Theme.lock_body_font_family
                            font.pixelSize: Theme.lock_status_font_size
                        }

                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 16

                            Repeater {
                                model: [
                                    {
                                        icon: "󰒲",
                                        label: "Suspend",
                                        process: suspendProcess
                                    },
                                    {
                                        icon: "󰤄",
                                        label: "Sleep",
                                        process: sleepProcess
                                    },
                                    {
                                        icon: "󰑓",
                                        label: "Restart",
                                        process: rebootProcess
                                    },
                                    {
                                        icon: "󰐥",
                                        label: "Shutdown",
                                        process: shutdownProcess
                                    }
                                ]

                                Rectangle {
                                    id: powerOption
                                    required property var modelData
                                    property bool hovered: powerMouse.containsMouse
                                    width: 90
                                    height: 64
                                    radius: Theme.radius_normal * 2
                                    color: hovered ? Theme.color_overlay_light : "transparent"

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: Animations.duration_hover
                                            easing.type: Animations.easing_standard
                                        }
                                    }

                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 6

                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: powerOption.modelData.icon
                                            color: Theme.color_text
                                            font.family: Theme.font_family_icon
                                            font.pixelSize: 22
                                        }

                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: powerOption.modelData.label
                                            color: Theme.color_text
                                            font.family: Theme.lock_body_font_family
                                            font.pixelSize: Theme.lock_status_font_size
                                        }
                                    }

                                    MouseArea {
                                        id: powerMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: powerOption.modelData.process.running = true
                                    }
                                }
                            }
                        }
                    }

                    Component.onCompleted: passwordInput.forceActiveFocus()
                    onActiveFocusChanged: {
                        if (activeFocus && root.locked)
                            passwordInput.forceActiveFocus();
                    }
                }
            }
        }
    }
}
