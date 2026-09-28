import SwiftUI

extension Color {
    static let widgetNight = Color(red: 0x15 / 255, green: 0x15 / 255, blue: 0x1A / 255)
    static let widgetDone = Color(red: 0x4A / 255, green: 0xDE / 255, blue: 0x80 / 255)
}

enum WidgetLinks {
    static let today = URL(string: "trekcompanion://today")!
    static let addExpense = URL(string: "trekcompanion://add-expense")!

    static func converter(amount: Double?) -> URL {
        URL(string: "trekcompanion://converter?amount=\(amount ?? 0)")!
    }
}
