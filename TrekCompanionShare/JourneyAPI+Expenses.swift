import Foundation

extension JourneyAPI {
    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()

    struct TripInfo: Decodable {
        let currency: String
        let startDate: String?
        let endDate: String?

        var days: ClosedRange<String>? {
            guard let startDate, let endDate, startDate <= endDate else { return nil }
            return startDate...endDate
        }
    }

    func trip(_ tripID: Int) async throws -> TripInfo {
        struct Envelope: Decodable { let trip: TripInfo }
        let envelope: Envelope = try await request("GET", "api/trips/\(tripID)")
        return envelope.trip
    }

    func myID() async throws -> Int {
        struct Envelope: Decodable {
            struct User: Decodable { let id: Int }
            let user: User
        }
        let envelope: Envelope = try await request("GET", "api/auth/me")
        return envelope.user.id
    }

    func memberIDs(_ tripID: Int) async throws -> [Int] {
        struct Member: Decodable { let id: Int }
        struct Roster: Decodable { let owner: Member; let members: [Member] }
        let roster: Roster = try await request("GET", "api/trips/\(tripID)/members")
        return ([roster.owner] + roster.members).map(\.id)
    }

    func addExpense(_ input: ExpenseInput, tripID: Int) async throws -> Int {
        struct Envelope: Decodable {
            struct Item: Decodable { let id: Int }
            let item: Item
        }
        let envelope: Envelope = try await request("POST", "api/trips/\(tripID)/budget", body: Self.encoder.encode(input))
        return envelope.item.id
    }

    func uploadReceipt(_ file: URL, expenseID: Int, tripID: Int) async throws {
        let boundary = "Boundary-\(UUID().uuidString)"
        let mimeType = file.pathExtension == "png" ? "image/png" : "image/jpeg"
        var body = Data()
        for (name, value) in ["budget_item_id": "\(expenseID)", "description": "Receipt"] {
            body.append(Data("--\(boundary)\r\nContent-Disposition: form-data; name=\"\(name)\"\r\n\r\n\(value)\r\n".utf8))
        }
        body.append(Data("--\(boundary)\r\nContent-Disposition: form-data; name=\"file\"; filename=\"receipt-\(expenseID).\(file.pathExtension)\"\r\nContent-Type: \(mimeType)\r\n\r\n".utf8))
        body.append(try Data(contentsOf: file))
        body.append(Data("\r\n--\(boundary)--\r\n".utf8))
        _ = try await data("POST", "api/trips/\(tripID)/files", body: body, contentType: "multipart/form-data; boundary=\(boundary)")
    }
}
