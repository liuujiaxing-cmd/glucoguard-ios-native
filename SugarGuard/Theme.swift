import SwiftUI

struct AppTheme {
    // 主色调：医疗蓝（沉稳、信任）
    static let primary = Color(hex: "0052CC")
    // 辅助色：健康绿（达标）
    static let success = Color(hex: "36B37E")
    // 警告色：活力橙（轻微超标）
    static let warning = Color(hex: "FFAB00")
    // 危险色：警示红（严重超标）
    static let danger = Color(hex: "FF5630")
    // 背景色：极淡的灰蓝，比纯白更护眼
    static let background = Color(hex: "F4F5F7")
    // 卡片背景
    static let cardBackground = Color.white
    
    // 字体颜色
    static let textPrimary = Color(hex: "172B4D")
    static let textSecondary = Color(hex: "5E6C84")
    
    // 渐变色：用于卡片背景或按钮
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "0052CC"), Color(hex: "2684FF")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// 简单的 Hex 颜色扩展
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// 统一的卡片样式修饰符
struct ModernCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

extension View {
    func modernCard() -> some View {
        modifier(ModernCardStyle())
    }
}
