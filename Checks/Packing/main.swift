import Foundation

@main
struct PackingCheck {
    static func main() throws {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let assignedJSON = #"{"id":42,"name":"Charger","checked":0,"quantity":2,"bag_id":7}"#
        let assigned = try decoder.decode(PackingItem.self, from: Data(assignedJSON.utf8))
        precondition(assigned.bagId == 7)
        let legacyJSON = #"{"id":43,"name":"Passport","checked":1}"#
        let legacy = try decoder.decode(PackingItem.self, from: Data(legacyJSON.utf8))
        precondition(legacy.bagId == nil && legacy.isPacked)

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let input = PackingInput(name: assigned.name, category: nil, quantity: 2, bagId: assigned.bagId)
        let data = try encoder.encode(input)
        let body = try JSONSerialization.jsonObject(with: data) as! [String: NSObject]
        precondition(body["bag_id"] == NSNumber(value: 7))
        precondition(body["checked"] == nil)

        let unassigned = PackingInput(name: "Charger", category: nil, quantity: 2, bagId: nil)
        let clearedData = try encoder.encode(unassigned)
        let cleared = try JSONSerialization.jsonObject(with: clearedData) as! [String: NSObject]
        precondition(cleared["bag_id"] is NSNull, "Removing a bag must send null, not omit the assignment.")

        let bagJSON = #"{"id":7,"name":"Backpack","color":"#6366f1","members":[],"total_weight_grams":500}"#
        let bag = try decoder.decode(PackingBag.self, from: Data(bagJSON.utf8))
        precondition(bag.id == assigned.bagId && bag.name == "Backpack")
        print("Packing API checks passed: assigned bags, legacy items, preserved checked state, and explicit unassignment.")
    }
}
