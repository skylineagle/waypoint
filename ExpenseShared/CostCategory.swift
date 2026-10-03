import SwiftUI

enum CostCategory: String, CaseIterable, Identifiable {
    case accommodation, food, groceries, transport, flights, activities, sightseeing
    case shopping, fees, health, tips, fuel, parking, other

    var id: Self { self }

    init(stored: String?) {
        let key = stored?.trimmingCharacters(in: .whitespaces).lowercased() ?? ""
        self = CostCategory(rawValue: key) ?? Self.legacy[key] ?? .other
    }

    var label: String {
        rawValue.capitalized
    }

    var symbol: String {
        switch self {
        case .accommodation: "bed.double.fill"
        case .food: "fork.knife"
        case .groceries: "cart.fill"
        case .transport: "bus.fill"
        case .flights: "airplane"
        case .activities: "ticket.fill"
        case .sightseeing: "camera.fill"
        case .shopping: "bag.fill"
        case .fees: "doc.text.fill"
        case .health: "heart.text.square.fill"
        case .tips: "dollarsign.circle.fill"
        case .fuel: "fuelpump.fill"
        case .parking: "parkingsign.circle.fill"
        case .other: "ellipsis"
        }
    }

    var color: Color {
        switch self {
        case .accommodation: Color(hex: 0x16A34A)
        case .food: Color(hex: 0xEA580C)
        case .groceries: Color(hex: 0x65A30D)
        case .transport: Color(hex: 0x2563EB)
        case .flights: Color(hex: 0x0EA5E9)
        case .activities: Color(hex: 0x9333EA)
        case .sightseeing: Color(hex: 0xDB2777)
        case .shopping: Color(hex: 0xE11D48)
        case .fees: Color(hex: 0x475569)
        case .health: Color(hex: 0xDC2626)
        case .tips: Color(hex: 0xD97706)
        case .fuel: Color(hex: 0xF59E0B)
        case .parking: Color(hex: 0x3B82F6)
        case .other: Color(hex: 0x6B7280)
        }
    }

    private static let legacy: [String: CostCategory] = [
        "flight": .flights, "plane": .flights,
        "train": .transport, "bus": .transport, "car": .transport, "car rental": .transport, "ferry": .transport,
        "boat": .transport, "taxi": .transport, "transfer": .transport, "transportation": .transport,
        "hotel": .accommodation, "lodging": .accommodation, "hostel": .accommodation,
        "restaurant": .food, "dining": .food, "meal": .food, "meals": .food,
        "grocery": .groceries, "activity": .activities, "sights": .sightseeing, "shop": .shopping,
        "fee": .fees, "medical": .health, "tip": .tips, "gas": .fuel, "petrol": .fuel,
        "parkings": .parking, "car park": .parking, "misc": .other,
    ]
}
