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
            return // Mac sans notch : l'app reste en mémoire sans rien afficher.
        }

        let window = makeWindow(frame: frame)
        window.contentView = NSHostingView(
            rootView: NotchOverlayView().environmentObject(statusWatcher)
        )
        window.orderFrontRegardless()
        self.window = window
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
        window.level = .statusBar // au-dessus de la menu bar
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        window.isReleasedWhenClosed = false
        return window
    }
}
