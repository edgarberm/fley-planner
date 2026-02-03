import SwiftUI

struct AdaptiveTextLayout<Content: View>: View {
    let content: Content
    let fontWeight: Font.Weight
    let lineSpacing: CGFloat
    let itemSpacing: CGFloat
    
    @State private var availableWidth: CGFloat = 0
    
    init(
        fontWeight: Font.Weight = .bold,
        lineSpacing: CGFloat = 4,
        itemSpacing: CGFloat = 6,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.fontWeight = fontWeight
        self.lineSpacing = lineSpacing
        self.itemSpacing = itemSpacing
    }
    
    var body: some View {
        GeometryReader { geometry in
            content
                .environment(\.adaptiveTextConfig, config(for: geometry.size.width))
                .onAppear {
                    availableWidth = geometry.size.width
                }
                .onChange(of: geometry.size.width) { _, newWidth in
                    availableWidth = newWidth
                }
        }
    }
    
    private func config(for width: CGFloat) -> AdaptiveTextConfig {
        // 📱 Breakpoints inteligentes
        switch width {
        case 0..<280:      // iPhone SE
            return AdaptiveTextConfig(
                fontSize: 24,
                iconSize: 28,
                itemSpacing: 4,
                lineSpacing: lineSpacing,
                fontWeight: fontWeight
            )
        case 280..<330:    // iPhone 13 mini
            return AdaptiveTextConfig(
                fontSize: 28,
                iconSize: 32,
                itemSpacing: 5,
                lineSpacing: lineSpacing,
                fontWeight: fontWeight
            )
        case 330..<380:    // iPhone 14/15/16 Pro
            return AdaptiveTextConfig(
                fontSize: 32,
                iconSize: 36,
                itemSpacing: itemSpacing,
                lineSpacing: lineSpacing,
                fontWeight: fontWeight
            )
        default:           // iPhone Pro Max, iPad
            return AdaptiveTextConfig(
                fontSize: 34,
                iconSize: 38,
                itemSpacing: itemSpacing,
                lineSpacing: lineSpacing,
                fontWeight: fontWeight
            )
        }
    }
}

// MARK: - Configuration Model

struct AdaptiveTextConfig {
    let fontSize: CGFloat
    let iconSize: CGFloat
    let itemSpacing: CGFloat
    let lineSpacing: CGFloat
    let fontWeight: Font.Weight
}

// MARK: - Environment Key

private struct AdaptiveTextConfigKey: EnvironmentKey {
    static let defaultValue = AdaptiveTextConfig(
        fontSize: 34,
        iconSize: 38,
        itemSpacing: 6,
        lineSpacing: 4,
        fontWeight: .bold
    )
}

extension EnvironmentValues {
    var adaptiveTextConfig: AdaptiveTextConfig {
        get { self[AdaptiveTextConfigKey.self] }
        set { self[AdaptiveTextConfigKey.self] = newValue }
    }
}

// MARK: - Line Component

/// Representa una línea de texto con posibles iconos intercalados
struct Line<Content: View>: View {
    @Environment(\.adaptiveTextConfig) private var config
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        HStack(spacing: config.itemSpacing) {
            content
        }
        .font(.system(size: config.fontSize, weight: config.fontWeight))
        .minimumScaleFactor(0.8)
        .lineLimit(nil)
    }
}

// MARK: - Icon Component

/// Icono adaptativo que se escala según la configuración
struct Icon: View {
    @Environment(\.adaptiveTextConfig) private var config
    let name: String
    
    init(_ name: String) {
        self.name = name
    }
    
    var body: some View {
        Image(name)
            .resizable()
            .scaledToFit()
            .frame(width: config.iconSize, height: config.iconSize)
            .baselineOffset(-2)
    }
}

// MARK: - Container for Lines

/// Vista que organiza múltiples líneas con el spacing correcto
struct Lines<Content: View>: View {
    @Environment(\.adaptiveTextConfig) private var config
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: config.lineSpacing) {
            content
        }
    }
}
