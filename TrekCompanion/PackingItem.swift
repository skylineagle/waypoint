import Foundation

struct PackingItem: Decodable, Identifiable, Hashable {
    let id: Int
    var name: String
    var checked: Int
    var category: String?
    var quantity: Int?

    var isPacked: Bool { checked != 0 }
}

struct PackingInput: Encodable {
    var name: String
    var category: String?
    var quantity: Int
}
