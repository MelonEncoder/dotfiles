pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property var actions: [
        {
            action: "lock",
            iconName: "system-lock-screen"
        },
        {
            action: "logout",
            iconName: "system-log-out"
        },
        {
            action: "suspend",
            iconName: "system-suspend"
        },
        {
            action: "reboot",
            iconName: "system-reboot"
        },
        {
            action: "poweroff",
            iconName: "system-shutdown"
        }
    ]

    function runAction(action: string): void {
        if (action === "poweroff")
            poweroff();
        if (action === "reboot")
            reboot();
        if (action === "suspend")
            suspend();
        if (action === "logout")
            logout();
        if (action === "lock")
            lock();
    }

    function poweroff(): void {
        poweroffProcess.running = true;
    }

    function reboot(): void {
        rebootProcess.running = true;
    }

    function suspend(): void {
        suspendProcess.running = true;
    }

    function logout(): void {
        logoutProcess.running = true;
    }

    function lock(): void {
        lockProcess.running = true;
    }

    Process {
        id: poweroffProcess
        command: ["systemctl", "poweroff"]
    }

    Process {
        id: rebootProcess
        command: ["systemctl", "reboot"]
    }

    Process {
        id: suspendProcess
        command: ["systemctl", "suspend"]
    }

    Process {
        id: logoutProcess
        command: ["hyprctl", "dispatch", "exit"]
    }

    Process {
        id: lockProcess
        command: ["qs", "ipc", "call", "lock", "lock"]
    }
}
