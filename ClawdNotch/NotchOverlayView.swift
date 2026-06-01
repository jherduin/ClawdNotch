import SwiftUI

/// Vue de l'overlay. Pilotée par l'état du `StatusWatcher`, elle dessine un
/// halo épousant le contour du notch. Le notch est un signal *ambiant* : les
/// animations restent volontairement subtiles.
struct NotchOverlayView: View {

    @EnvironmentObject private var watcher: StatusWatcher
    @State private var pulse = false

    var body: some View {
        ZStack {
            if let style = style(for: watcher.status) {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(style.color, lineWidth: 3)
                    .padding(NotchGeometry.glowPadding)
                    .shadow(color: style.color.opacity(0.9), radius: pulse ? 10 : 4)
                    .opacity(pulse ? 1.0 : 0.45)
                    .onAppear { animate(style) }
                    .onChange(of: watcher.status) { animate(style) }
            }
        }
        .allowsHitTesting(false)
        .animation(.easeInOut(duration: 0.3), value: watcher.status)
    }

    // MARK: - Styles par état

    private struct VisualStyle {
        let color: Color
        let period: Double // durée d'un demi-cycle de pulsation
    }

    private func style(for status: NotchStatus) -> VisualStyle? {
        switch status {
        case .working:
            // Halo orange animé, rythme soutenu.
            return VisualStyle(color: .orange, period: 0.6)
        case .waiting:
            // Pulsation bleue douce et lente.
            return VisualStyle(color: .blue, period: 1.5)
        case .idle:
            // Invisible.
            return nil
        }
    }

    private func animate(_ style: VisualStyle) {
        pulse = false
        withAnimation(.easeInOut(duration: style.period).repeatForever(autoreverses: true)) {
            pulse = true
        }
    }
}
