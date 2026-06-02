import AppKit
import os

let notchLog = Logger(subsystem: "com.jherduin.clawdnotch", category: "notch")

/// Calcule la position et les dimensions du notch à partir des informations
/// fournies par `NSScreen`. Gère gracieusement les Macs sans notch.
enum NotchGeometry {

    /// Marge (en points) ajoutée autour du notch pour laisser respirer le halo.
    static let glowPadding: CGFloat = 30

    /// Rayon des deux coins *inférieurs* du notch — les seuls visibles. Le bord
    /// supérieur étant au ras de l'écran (hors champ), ses coins n'existent pas
    /// visuellement. Valeur calée sur le rayon physique du notch des MacBook Pro.
    static let cornerRadius: CGFloat = 10

    /// Premier écran disposant d'un notch (inset haut + zones auxiliaires).
    ///
    /// On ne se fie pas à `NSScreen.main` : dans une app `.accessory` sans fenêtre
    /// clé, `main` peut être `nil` ou pointer vers un écran externe.
    static func screenWithNotch() -> NSScreen? {
        NSScreen.screens.first { screen in
            screen.safeAreaInsets.top > 0
                && screen.auxiliaryTopLeftArea != nil
                && screen.auxiliaryTopRightArea != nil
        }
    }

    /// Rectangle couvrant exactement le notch, en coordonnées écran globales
    /// (origine en bas à gauche). Renvoie `nil` si aucun écran n'a de notch.
    ///
    /// La largeur du notch est déduite des zones auxiliaires de la menu bar
    /// situées de part et d'autre de la caméra (`auxiliaryTopLeftArea` /
    /// `auxiliaryTopRightArea`), disponibles depuis macOS 12.
    static func notchFrame(for screen: NSScreen? = nil) -> CGRect? {
        guard let screen = screen ?? screenWithNotch() else {
            notchLog.info("Aucun écran avec notch détecté")
            return nil
        }

        let topInset = screen.safeAreaInsets.top
        guard topInset > 0 else {
            notchLog.info("safeAreaInsets.top == 0 (pas de notch)")
            return nil
        }

        guard
            let leftArea = screen.auxiliaryTopLeftArea,
            let rightArea = screen.auxiliaryTopRightArea
        else {
            notchLog.info("Zones auxiliaires indisponibles")
            return nil
        }

        let notchWidth = rightArea.minX - leftArea.maxX
        guard notchWidth > 0 else {
            notchLog.info("Largeur de notch invalide")
            return nil
        }

        // Les zones auxiliaires sont exprimées dans le repère de l'écran ;
        // on les ramène en coordonnées globales via l'origine du `frame`.
        let originX = screen.frame.origin.x + leftArea.maxX
        let originY = screen.frame.maxY - topInset

        let frame = CGRect(x: originX, y: originY, width: notchWidth, height: topInset)
        notchLog.info("Notch détecté: \(frame.debugDescription, privacy: .public)")
        return frame
    }

    /// Frame de la fenêtre overlay : le notch élargi du `glowPadding` pour que
    /// le halo puisse déborder. Le débordement en haut sort de l'écran (invisible),
    /// ce qui est sans conséquence.
    static func overlayFrame(for screen: NSScreen? = nil) -> CGRect? {
        notchFrame(for: screen)?.insetBy(dx: -glowPadding, dy: -glowPadding)
    }
}
