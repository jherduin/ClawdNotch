import SwiftUI

/// Vue de l'overlay. Pilotée par l'état du `StatusWatcher`, elle trace une fine
/// lueur épousant la silhouette *visible* du notch (côtés verticaux + bas aux
/// coins arrondis). Le bord supérieur étant au ras de l'écran, il reste hors
/// champ : seul le pourtour inférieur est perçu.
///
/// Parti pris : on ne pose pas une bordure *autour* du notch, on fait *suinter*
/// une lumière de son bord. D'où un trait hairline (≈1 pt), un dégradé qui
/// concentre l'éclat sur le bord inférieur et s'estompe en remontant vers le
/// bezel, et une lueur douce — moitié moins lourde que la précédente.
///
/// Le contour est **toujours** présent dans la hiérarchie : seule son opacité
/// varie selon l'état (idle → invisible). On évite ainsi l'insertion/retrait
/// conditionnelle d'une sous-vue, que `NSHostingView` ne redessine pas
/// correctement en fenêtre AppKit. Le notch est un signal *ambiant* : les
/// animations restent volontairement subtiles.
struct NotchOverlayView: View {

    @EnvironmentObject private var watcher: StatusWatcher
    @State private var pulse = false

    /// Inset du contour dans la fenêtre overlay. À 1 pt de `glowPadding` : le
    /// tracé colle au bord du notch (1 pt à l'extérieur seulement), pour
    /// l'épouser au plus près sans s'enfoncer dans le noir de la caméra.
    private var contourInset: CGFloat { NotchGeometry.glowPadding - 1 }

    var body: some View {
        let current = style(for: watcher.status)
        notchOutline
            .stroke(strokeGradient(current.color), lineWidth: pulse ? 2.8 : 2.2)
            .padding(contourInset)
            // Lueur qui irradie vers l'écran (le haut étant hors champ). Assez
            // présente pour accrocher l'œil, encore diffuse pour rester ambiante.
            .shadow(color: current.color.opacity(0.7 * current.glow), radius: pulse ? 10 : 7)
            .shadow(color: current.color.opacity(0.35 * current.glow), radius: pulse ? 20 : 14)
            .opacity(current.isVisible ? (pulse ? 1.0 : 0.85) : 0)
            .allowsHitTesting(false)
            .animation(.easeInOut(duration: 0.3), value: watcher.status)
            .onAppear { animate(current) }
            .onChange(of: watcher.status) { animate(style(for: watcher.status)) }
    }

    /// Silhouette visible du notch : coins hauts droits (bord au ras de l'écran,
    /// hors champ), coins bas arrondis au rayon réel du notch.
    private var notchOutline: some Shape {
        UnevenRoundedRectangle(
            topLeadingRadius: 0,
            bottomLeadingRadius: NotchGeometry.cornerRadius,
            bottomTrailingRadius: NotchGeometry.cornerRadius,
            topTrailingRadius: 0,
            style: .continuous
        )
    }

    /// Dégradé vertical : éclat plein sur le bord inférieur (le plus visible),
    /// estompé en remontant les côtés vers le bezel. Donne l'impression d'une
    /// lumière qui affleure le notch plutôt que d'un trait uniforme.
    private func strokeGradient(_ color: Color) -> LinearGradient {
        LinearGradient(
            colors: [color.opacity(0.6), color],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Styles par état

    private struct VisualStyle {
        let color: Color
        let period: Double // durée d'un demi-cycle de pulsation
        let isVisible: Bool
        var glow: Double = 1 // multiplicateur d'intensité de la lueur
    }

    private func style(for status: NotchStatus) -> VisualStyle {
        switch status {
        case .working:
            // Halo orange animé, rythme soutenu.
            return VisualStyle(color: .orange, period: 0.6, isVisible: true)
        case .waiting:
            // Pulsation bleue douce et lente, lueur plus appuyée (le bleu rayonne
            // moins que l'orange) pour qu'elle accroche bien l'œil.
            return VisualStyle(color: .blue, period: 1.5, isVisible: true, glow: 1.4)
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
