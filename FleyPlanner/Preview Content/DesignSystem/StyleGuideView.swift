//
//  StyleGuideView.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 3/2/26.
//

import SwiftUI

struct StyleGuideView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 40) {
                    
                    // --- 1. TIPOGRAFÍA ---
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Typography & Hierarchy")
                        Group {
                            TextItem(label: "Large Title", font: .largeTitle, size: "34pt")
                            TextItem(label: "Title 1", font: .title, size: "28pt")
                            TextItem(label: "Title 2", font: .title2, size: "22pt")
                            TextItem(label: "Title 3", font: .title3, size: "20pt")
                            TextItem(label: "Headline", font: .headline, size: "17pt (Bold)")
                            TextItem(label: "Body", font: .body, size: "17pt")
                            TextItem(label: "Callout", font: .callout, size: "16pt")
                            TextItem(label: "Subheadline", font: .subheadline, size: "15pt")
                            TextItem(label: "Footnote", font: .footnote, size: "13pt")
                            TextItem(label: "Caption", font: .caption, size: "12pt")
                            TextItem(label: "Caption Mono", font: .system(.caption, design: .monospaced), size: "12pt")
                        }
                    }
                    
                    // --- 2. PALETA DE GRISES (La base de la UI) ---
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "UI Grays (Neutrals)")
                        Text("Fundamentales para bordes, fondos de cards y textos secundarios.")
                            .font(.caption).foregroundColor(.secondary)
                        
                        VStack(spacing: 8) {
                            ColorRow(name: "System Gray 1", color: .systemGray)
                            ColorRow(name: "System Gray 2", color: .systemGray2)
                            ColorRow(name: "System Gray 3", color: .systemGray3)
                            ColorRow(name: "System Gray 4", color: .systemGray4)
                            ColorRow(name: "System Gray 5", color: .systemGray5)
                            ColorRow(name: "System Gray 6", color: .systemGray6)
                        }
                    }
                    
                    // --- 3. COLORES SEMÁNTICOS (Acción y Estado) ---
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Semantic & Action")
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ColorBox(name: "Blue (Info)", color: .blue)
                            ColorBox(name: "Green (Success)", color: .green)
                            ColorBox(name: "Indigo (Focus)", color: .indigo)
                            ColorBox(name: "Orange (Warning)", color: .orange)
                            ColorBox(name: "Red (Error)", color: .red)
                            ColorBox(name: "Pink (Family)", color: .pink)
                            ColorBox(name: "Teal (Health)", color: .teal)
                            ColorBox(name: "Mint (Finance)", color: .mint)
                        }
                    }
                    
                    // --- 4. OPACIDADES (El toque "Notion") ---
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Material Opacity")
                        Text("Usa estas opacidades sobre el color Primary para textos y separadores.")
                            .font(.caption).foregroundColor(.secondary)
                        
                        HStack(spacing: 10) {
                            OpacityCircle(percentage: 0.8, label: "Emphasis")
                            OpacityCircle(percentage: 0.6, label: "Secondary")
                            OpacityCircle(percentage: 0.3, label: "Tertiary")
                            OpacityCircle(percentage: 0.1, label: "Quaternary")
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Fley Foundations")
            .background(Color(uiColor: .systemBackground))
        }
    }
}

// MARK: - Componentes de Soporte

struct ColorRow: View {
    let name: String
    let color: Color
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 40, height: 40)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.primary.opacity(0.05), lineWidth: 1))
            
            VStack(alignment: .leading) {
                Text(name).font(.system(.subheadline, design: .monospaced))
            }
            Spacer()
        }
        .padding(8)
        .background(Color.primary.opacity(0.03))
        .cornerRadius(10)
    }
}

struct OpacityCircle: View {
    let percentage: Double
    let label: String
    
    var body: some View {
        VStack {
            Circle()
                .fill(Color.primary.opacity(percentage))
                .frame(width: 50, height: 50)
            Text(label).font(.system(size: 9, weight: .bold))
            Text("\(Int(percentage * 100))%").font(.system(size: 9))
        }
        .frame(maxWidth: .infinity)
    }
}

// Extensiones de Color para acceder a los grises de sistema
extension Color {
    static let systemGray = Color(uiColor: .systemGray)
    static let systemGray2 = Color(uiColor: .systemGray2)
    static let systemGray3 = Color(uiColor: .systemGray3)
    static let systemGray4 = Color(uiColor: .systemGray4)
    static let systemGray5 = Color(uiColor: .systemGray5)
    static let systemGray6 = Color(uiColor: .systemGray6)
}

// MARK: - Componentes Auxiliares

struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title.uppercased())
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.secondary)
        //.letterSpacing(1.2)
    }
}

struct TextItem: View {
    let label: String
    let font: Font
    let size: String
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading) {
                Text(label)
                    .font(font)
                Text(size)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct ColorBox: View {
    let name: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(color)
                .frame(height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                )
            Text(name)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .lineLimit(1)
        }
    }
}

#Preview {
    StyleGuideView()
}
