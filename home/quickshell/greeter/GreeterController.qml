import Quickshell
import Quickshell.Services.Greetd
import QtQuick

QtObject {
    id: root

    readonly property string user: Quickshell.env("GREETER_USER") || ""
    readonly property var session: (Quickshell.env("GREETER_SESSION") || "start-hyprland").split(" ")
    property string pendingPassword: ""
    property string authMessage: ""
    property bool authMessageIsError: false
    property bool authenticating: false
    property int failureSerial: 0

    function authenticate(password: string): void {
        if (authenticating || password.length === 0)
            return;

        pendingPassword = password;
        authMessage = "Checking password…";
        authMessageIsError = false;
        authenticating = true;
        Greetd.createSession(user);
    }

    function fail(message: string): void {
        authenticating = false;
        pendingPassword = "";
        authMessage = message;
        authMessageIsError = true;
        failureSerial++;
    }

    property Connections greetd: Connections {
        target: Greetd

        function onAuthMessage(message: string, error: bool, responseRequired: bool, echoResponse: bool): void {
            if (responseRequired) {
                Greetd.respond(root.pendingPassword);
                root.pendingPassword = "";
            } else if (error) {
                root.authMessage = message;
                root.authMessageIsError = true;
            }
        }

        function onAuthFailure(message: string): void {
            root.fail("That password didn't work");
        }

        function onError(error: string): void {
            Greetd.cancelSession();
            root.fail(error);
        }

        function onReadyToLaunch(): void {
            root.authMessage = "";
            Greetd.launch(root.session, [], true);
        }
    }
}
