import SwiftUI

/// Vue de l'overlay. Pilotée par l'état du `StatusWatcher`, elle dessine un
/// contour lumineux épousant les bords *visibles* du notch (côtés + bas), avec
/// une lueur qui déborde vers le bas dans l'écran. Le notch étant tout en haut,
/// son bord supérieur est hors écran : seul le pourtour inférieur est visible.
///
/// Le contour est **toujours** présent dans la hiérarchie : seule son opacité
/// varie selon l'état (idle → invisible). On évite ainsi l'insertion/retrait
/// conditionnelle d'une sous-vue, que `NSHostingView` ne redessine pas
/// correctement en fenêtre AppKit. Le notch est un signal *ambiant* : les
/// animations restent volontairement subtiles.
struct NotchOverlayView: View {

    @EnvironmentObject private var watcher: StatusWatcher
    @State private var pulse = false

    /// Inset du contour dans la fenêtre overlay. Inférieur à `glowPadding` :
    /// le trait déborde ainsi de quelques points *à l'extérieur* du notch
    /// (côtés et bas dans la zone visible de l'écran), pour bien épouser ses bords.
    private var contourInset: CGFloat { NotchGeometry.glowPadding - 5 }

    var body: some View {
        let current = style(for: watcher.status)
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .stroke(current.color, lineWidth: 4)
            .padding(contourInset)
            // Double halo coloré qui irradie vers l'extérieur (donc vers le bas,
            // le haut étant hors écran).
            .shadow(color: current.color.opacity(0.9), radius: pulse ? 12 : 7)
            .shadow(color: current.color.opacity(0.55), radius: pulse ? 22 : 13)
            .opacity(current.isVisible ? (pulse ? 1.0 : 0.7) : 0)
            .allowsHitTesting(false)
            .animation(.easeInOut(duration: 0.3), value: watcher.status)
            .onAppear { animate(current) }
            .onChange(of: watcher.status) { animate(style(for: watcher.status)) }
    }

    // MARK: - Styles par état

    private struct VisualStyle {
        let color: Color
        let period: Double // durée d'un demi-cycle de pulsation
        let isVisible: Bool
    }

    private func style(for status: NotchStatus) -> VisualStyle {
        switch status {
        case .working:
            // Halo orange animé, rythme soutenu.
            return VisualStyle(color: .orange, period: 0.6, isVisible: true)
        case .waiting:
            // Pulsation bleue douce et lente.
            return VisualStyle(color: .blue, period: 1.5, isVisible: true)
        case .idle:
            // Invisible (la couleur est sans importance).
            return VisualStyle(color: .clear, period: 1, isVisible: false)
        }
    }

    private func animate(_ style: VisualStyle) {
        pulse = false
        guard style.isVisible else { return } // idle : pas d'animation
        withAnimation(.easeInOut(duration: style.period).repeatForever(autoreverses: true)) {
            pulse = true
        }
    }
}
