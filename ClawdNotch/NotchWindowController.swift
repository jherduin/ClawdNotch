import AppKit
import SwiftUI

/// Crée et positionne la fenêtre overlay transparente au-dessus de la menu bar.
/// Ne crée rien si l'écran n'a pas de notch.
final class NotchWindowController {

    private var window: NSWindow?
    private let statusWatcher: StatusWatcher

    init(statusWatcher: StatusWatcher) {
        self.statusWatcher = statusWatcher
    }

    /// Affiche l'overlay si un notch est détecté sur l'écran principal.
    func showIfNotchAvailable() {
        guard let frame = NotchGeometry.overlayFrame() else {
            notchLog.info("Pas de notch : aucune fenêtre créée")
            return // Mac sans notch : l'app reste en mémoire sans rien afficher.
        }

        let window = makeWindow(frame: frame)
        let hosting = NSHostingView(
            rootView: NotchOverlayView().environmentObject(statusWatcher)
        )
        hosting.frame = CGRect(origin: .zero, size: frame.size)
        hosting.autoresizingMask = [.width, .height]
        window.contentView = hosting
        window.setFrame(frame, display: true)
        window.orderFrontRegardless()
        self.window = window
        notchLog.info("Overlay affiché: \(frame.debugDescription, privacy: .public)")
    }

    private func makeWindow(frame: CGRect) -> NSWindow {
        let window = NSWindow(
            contentRect: frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.ignoresMouseEvents = true
        // Juste au-dessus de la barre de menus système, pour dessiner autour du notch.
        let menuBarLevel = CGWindowLevelForKey(.mainMenuWindow)
        window.level = NSWindow.Level(rawValue: Int(menuBarLevel) + 1)
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        window.isReleasedWhenClosed = false
        return window
    }
}
