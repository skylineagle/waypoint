import SwiftUI

struct PackingCategoryStyle {
    let color: Color
    let symbol: String

    private static let colors: [Color] = [
        Color(hex: 0x0A84FF), Color(hex: 0xBF5AF2), Color(hex: 0xFF9F0A),
        Color(hex: 0x30D158), Color(hex: 0xFF375F), Color(hex: 0x64D2FF),
    ]
    private static let symbols = ["backpack.fill", "suitcase.rolling.fill", "bag.fill", "tshirt.fill", "shoe.fill", "briefcase.fill"]

    init(category: String) {
        let seed = category.unicodeScalars.reduce(0) { $0 &+ Int($1.value) }
        color = Self.colors[seed % Self.colors.count]
        symbol = Self.symbols[seed % Self.symbols.count]
    }
}
