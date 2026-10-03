import Foundation

struct PackingItem: Decodable, Identifiable, Hashable {
    let id: Int
    var name: String
    var checked: Int
    var category: String?
    var quantity: Int?
    var bagId: Int?

    var isPacked: Bool { checked != 0 }
}

struct PackingInput: Encodable {
    var name: String
    var category: String?
    var quantity: Int
    var bagId: Int? = nil

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(category, forKey: .category)
        try container.encode(quantity, forKey: .quantity)
        try container.encode(bagId, forKey: .bagId)
    }

    private enum CodingKeys: String, CodingKey {
        case name, category, quantity, bagId
    }
}
