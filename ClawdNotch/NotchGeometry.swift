import AppKit

/// Calcule la position et les dimensions du notch à partir des informations
/// fournies par `NSScreen`. Gère gracieusement les Macs sans notch.
enum NotchGeometry {

    /// Marge (en points) ajoutée autour du notch pour laisser respirer le halo.
    static let glowPadding: CGFloat = 8

    /// Rectangle couvrant exactement le notch, en coordonnées écran globales
    /// (origine en bas à gauche). Renvoie `nil` si l'écran n'a pas de notch.
    ///
    /// La largeur du notch est déduite des zones auxiliaires de la menu bar
    /// situées de part et d'autre de la caméra (`auxiliaryTopLeftArea` /
    /// `auxiliaryTopRightArea`), disponibles depuis macOS 12.
    static func notchFrame(for screen: NSScreen? = NSScreen.main) -> CGRect? {
        guard let screen else { return nil }

        let topInset = screen.safeAreaInsets.top
        guard topInset > 0 else { return nil } // Mac sans notch

        guard
            let leftArea = screen.auxiliaryTopLeftArea,
            let rightArea = screen.auxiliaryTopRightArea
        else { return nil }

        let notchWidth = rightArea.minX - leftArea.maxX
        guard notchWidth > 0 else { return nil }

        // Les zones auxiliaires sont exprimées dans le repère de l'écran ;
        // on les ramène en coordonnées globales via l'origine du `frame`.
        let originX = screen.frame.origin.x + leftArea.maxX
        let originY = screen.frame.maxY - topInset

        return CGRect(x: originX, y: originY, width: notchWidth, height: topInset)
    }

    /// Frame de la fenêtre overlay : le notch élargi du `glowPadding` pour que
    /// le halo puisse déborder. Le débordement en haut sort de l'écran (invisible),
    /// ce qui est sans conséquence.
    static func overlayFrame(for screen: NSScreen? = NSScreen.main) -> CGRect? {
        notchFrame(for: screen)?.insetBy(dx: -glowPadding, dy: -glowPadding)
    }
}
