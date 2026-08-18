pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Pam

Singleton {
    id: root

    property bool locked: false
    property bool authenticating: false
    property bool failedAttempt: false
    property string statusText: ""
    property string submittedSecret: ""
    property Component lockSurface: null

    readonly property string currentUser:
        (Quickshell.env("USER") || "") + ""

    function activateLock(): void {
        if (root.locked) {
            return;
        }

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

    function unlock(): void {
        root.locked = false;
        root.authenticating = false;
        root.failedAttempt = false;
        root.statusText = "";
        root.submittedSecret = "";
    }

    function submitSecret(secret: string): void {
        var value = (secret || "") + "";

        if (!root.locked || root.authenticating) {
            return;
        }

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
            root.activateLock()
        }
    }

    WlSessionLock {
        id: sessionLock

        locked: root.locked
        surface: root.lockSurface
    }

    PamContext {
        id: pam

        config: "quickshell"
        user: root.currentUser

        onPamMessage: {
            if (!root.authenticating) {
                return;
            }

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
                root.unlock();
                return;
            }

            root.statusText = result === PamResult.MaxTries ? "Too many failed attempts" : "Incorrect password";
        }

        onError: error => {
            root.authenticating = false;
            root.failedAttempt = true;
            root.submittedSecret = "";
            root.statusText = PamError.toString(error);
        }
    }

}
