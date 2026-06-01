import SwiftUI
import AppKit

/// Point d'entrée. App sans fenêtre principale ni icône Dock : elle se contente
/// d'installer l'overlay du notch et de surveiller le fichier de statut.
@main
struct ClawdNotchApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        // Scène neutre : aucune fenêtre visible n'est présentée.
        Settings {
            EmptyView()
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {

    private let statusWatcher = StatusWatcher()
    private var windowController: NotchWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Pas d'icône dans le Dock, app en arrière-plan.
        NSApp.setActivationPolicy(.accessory)

        windowController = NotchWindowController(statusWatcher: statusWatcher)
        windowController?.showIfNotchAvailable()

        statusWatcher.start()
    }
}
