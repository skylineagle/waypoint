import Foundation

struct PackingBag: Decodable, Identifiable, Hashable {
    let id: Int
    let name: String
    let color: String?
}

struct PackingBagInput: Encodable {
    let name: String
}
