import Foundation

enum SignInResult {
    case signedIn(Account)
    case needsCode(mfaToken: String)
}

struct TrekClient {
    let account: Account

    static var current: TrekClient? {
        Account.load().map(TrekClient.init)
    }

    static func isTrekServer(_ serverURL: URL) async -> Bool {
        guard let (data, status) = try? await send("GET", "api/auth/app-config", serverURL: serverURL, token: nil, body: nil),
              (200..<300).contains(status)
        else { return false }
        return (try? decoder.decode(AppConfig.self, from: data).version) != nil
    }

    static func signIn(serverURL: URL, email: String, password: String) async throws -> SignInResult {
        let body = LoginRequest(email: email, password: password, rememberMe: true)
        let response: LoginResponse = try await sendPublic("api/auth/login", serverURL: serverURL, body: body)
        if response.mfaRequired == true, let mfaToken = response.mfaToken {
            return .needsCode(mfaToken: mfaToken)
        }
        return .signedIn(try account(from: response, serverURL: serverURL, email: email, password: password))
    }

    static func verifyCode(_ code: String, mfaToken: String, serverURL: URL, email: String, password: String) async throws -> Account {
        let body = MfaRequest(mfaToken: mfaToken, code: code, rememberMe: true)
        let response: LoginResponse = try await sendPublic("api/auth/mfa/verify-login", serverURL: serverURL, body: body)
        return try account(from: response, serverURL: serverURL, email: email, password: password)
    }

    func trips() async throws -> [Trip] {
        try await request("GET", "api/trips", as: TripList.self).trips
    }

    func trip(id: Int) async throws -> Trip {
        try await request("GET", "api/trips/\(id)", as: TripEnvelope.self).trip
    }

    func photo(of place: StopPlace) async throws -> String? {
        let coordinates = place.lat.flatMap { latitude in place.lng.map { "coords:\(latitude),\($0)" } }
        guard let id = place.googlePlaceId ?? place.osmId ?? coordinates,
              let encodedID = id.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
        else { return nil }
        var query = URLComponents()
        query.queryItems = [URLQueryItem(name: "name", value: place.name)]
        if let latitude = place.lat, let longitude = place.lng {
            query.queryItems?.append(contentsOf: [
                URLQueryItem(name: "lat", value: String(latitude)),
                URLQueryItem(name: "lng", value: String(longitude)),
            ])
        }
        return try await request("GET", "api/maps/place-photo/\(encodedID)?\(query.percentEncodedQuery ?? "")", as: PlacePhoto.self).photoUrl
    }

    func image(at path: String) async throws -> Data {
        guard let url = TrekURL.resolve(path, on: account.serverURL)
        else { throw TrekError("The photo address is invalid.") }
        if url.scheme == account.serverURL.scheme, url.host == account.serverURL.host, url.port == account.serverURL.port {
            var (data, status) = try await Self.send("GET", url.absoluteString, serverURL: account.serverURL, token: Account.load()?.token ?? account.token, body: nil)
            if status == 401 {
                let token = try await reauthenticate()
                (data, status) = try await Self.send("GET", url.absoluteString, serverURL: account.serverURL, token: token, body: nil)
            }
            try Self.validate(data: data, status: status)
            return data
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        try Self.validate(data: data, status: (response as? HTTPURLResponse)?.statusCode ?? 0)
        return data
    }

    func defaultCurrency() async throws -> String? {
        try await request("GET", "api/settings", as: SettingsEnvelope.self).settings.defaultCurrency
    }

    func currentUserID() async throws -> Int {
        try await request("GET", "api/auth/me", as: UserEnvelope.self).user.id
    }

    func days(tripID: Int) async throws -> [TripDay] {
        try await request("GET", "api/trips/\(tripID)/days", as: DaysEnvelope.self).days
    }

    func segments(tripID: Int) async throws -> [TripSegment] {
        try await request("GET", "api/plugins/trip-segments/overview?tripId=\(tripID)", as: TripSegmentOverview.self).segments
    }

    func reservations(tripID: Int) async throws -> [Reservation] {
        try await request("GET", "api/trips/\(tripID)/reservations", as: ReservationsEnvelope.self).reservations
    }

    func stays(tripID: Int) async throws -> [Stay] {
        try await request("GET", "api/trips/\(tripID)/accommodations", as: StaysEnvelope.self).accommodations
    }

    func weather(latitude: Double, longitude: Double, date: String) async throws -> DayWeather {
        try await request("GET", "api/weather?lat=\(latitude)&lng=\(longitude)&date=\(date)&lang=en", as: DayWeather.self)
    }

    func members(tripID: Int) async throws -> [TripMember] {
        let roster = try await request("GET", "api/trips/\(tripID)/members", as: TripRoster.self)
        return [roster.owner] + roster.members
    }

    func settlement(tripID: Int, currency: String) async throws -> Settlement {
        try await request("GET", "api/trips/\(tripID)/budget/settlement?base=\(currency)", as: Settlement.self)
    }

    func expenses(tripID: Int) async throws -> [BudgetItem] {
        try await request("GET", "api/trips/\(tripID)/budget", as: BudgetItemList.self).items
    }

    func addExpense(_ input: ExpenseInput, tripID: Int) async throws -> BudgetItem {
        try await request("POST", "api/trips/\(tripID)/budget", body: try .json(input), as: BudgetItemEnvelope.self).item
    }

    func updateExpense(id: Int, _ input: ExpenseInput, tripID: Int) async throws -> BudgetItem {
        try await request("PUT", "api/trips/\(tripID)/budget/\(id)", body: try .json(input), as: BudgetItemEnvelope.self).item
    }

    func deleteExpense(id: Int, tripID: Int) async throws {
        _ = try await request("DELETE", "api/trips/\(tripID)/budget/\(id)", as: SuccessResponse.self)
    }

    func uploadReceipt(_ jpeg: Data, expenseID: Int, tripID: Int) async throws {
        let body = RequestBody.multipart(
            fields: ["budget_item_id": "\(expenseID)", "description": "Receipt"],
            file: jpeg,
            fileName: "receipt-\(expenseID).jpg",
            mimeType: "image/jpeg"
        )
        _ = try await request("POST", "api/trips/\(tripID)/files", body: body, as: SuccessResponse.self)
    }

    func hasTodos() async -> Bool {
        let plugins = try? await request("GET", "api/plugins", as: PluginList.self).plugins
        guard plugins?.contains(where: { $0.id == "trip-todos" }) == true else { return false }
        let addons = try? await request("GET", "api/addons", as: AddonList.self).addons
        return addons?.contains { $0.id == "packing" && $0.enabled } == true
    }

    func todos(tripID: Int) async throws -> [TodoItem] {
        try await request("GET", "api/trips/\(tripID)/todo", as: TodoList.self).items
    }

    func addTodo(_ input: TodoInput, tripID: Int) async throws -> TodoItem {
        try await request("POST", "api/trips/\(tripID)/todo", body: try .json(input), as: TodoEnvelope.self).item
    }

    func updateTodo(id: Int, _ input: TodoInput, tripID: Int) async throws -> TodoItem {
        try await request("PUT", "api/trips/\(tripID)/todo/\(id)", body: try .json(input), as: TodoEnvelope.self).item
    }

    func setTodo(id: Int, checked: Bool, tripID: Int) async throws {
        _ = try await request("PUT", "api/trips/\(tripID)/todo/\(id)", body: try .json(TodoCheck(checked: checked)), as: TodoEnvelope.self)
    }

    func deleteTodo(id: Int, tripID: Int) async throws {
        _ = try await request("DELETE", "api/trips/\(tripID)/todo/\(id)", as: SuccessResponse.self)
    }

    private func request<Response: Decodable>(
        _ method: String,
        _ path: String,
        body: RequestBody? = nil,
        as: Response.Type
    ) async throws -> Response {
        var (data, status) = try await Self.send(method, path, serverURL: account.serverURL, token: account.token, body: body)
        if status == 401 {
            let token = try await reauthenticate()
            (data, status) = try await Self.send(method, path, serverURL: account.serverURL, token: token, body: body)
        }
        try Self.validate(data: data, status: status)
        return try Self.decoder.decode(Response.self, from: data)
    }

    private func reauthenticate() async throws -> String {
        let result = try? await Self.signIn(serverURL: account.serverURL, email: account.email, password: account.password)
        guard case .signedIn(let refreshed)? = result else {
            throw TrekError("Your Trek session expired. Open Waypoint to sign in again.")
        }
        store(token: refreshed.token)
        return refreshed.token
    }

    private func store(token: String) {
        guard var latest = Account.load() else { return }
        latest.token = token
        latest.save()
    }

    private static func account(from response: LoginResponse, serverURL: URL, email: String, password: String) throws -> Account {
        guard let token = response.token else { throw TrekError("Trek didn't return a session.") }
        return Account(serverURL: serverURL, email: email, password: password, token: token)
    }

    private static func sendPublic<Response: Decodable>(_ path: String, serverURL: URL, body: some Encodable) async throws -> Response {
        let (data, status) = try await send("POST", path, serverURL: serverURL, token: nil, body: try .json(body))
        try validate(data: data, status: status)
        return try decoder.decode(Response.self, from: data)
    }

    private static func send(
        _ method: String,
        _ path: String,
        serverURL: URL,
        token: String?,
        body: RequestBody?
    ) async throws -> (Data, Int) {
        guard let url = TrekURL.resolve(path, on: serverURL) else { throw TrekError("The server address is invalid.") }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpShouldHandleCookies = false
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token {
            request.setValue("\(sessionCookie)=\(token)", forHTTPHeaderField: "Cookie")
        }
        if let body {
            request.setValue(body.contentType, forHTTPHeaderField: "Content-Type")
            request.httpBody = body.data
        }
        let (data, response) = try await URLSession.shared.data(for: request)
        let httpResponse = response as? HTTPURLResponse
        if token != nil, let renewed = httpResponse.flatMap(renewedToken) {
            TrekClient.current?.store(token: renewed)
        }
        return (data, httpResponse?.statusCode ?? 0)
    }

    private static func renewedToken(in response: HTTPURLResponse) -> String? {
        guard let url = response.url,
              let headers = response.allHeaderFields as? [String: String]
        else { return nil }
        let cookie = HTTPCookie.cookies(withResponseHeaderFields: headers, for: url)
            .first { $0.name == sessionCookie }
        return cookie.flatMap { $0.value.isEmpty ? nil : $0.value }
    }

    private static func validate(data: Data, status: Int) throws {
        guard !(200..<300).contains(status) else { return }
        let message = (try? decoder.decode(ErrorResponse.self, from: data))?.error
        throw TrekError(message ?? "Trek responded with status \(status).")
    }

    private static let sessionCookie = "trek_session"

    fileprivate static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}

private struct SettingsEnvelope: Decodable {
    struct Settings: Decodable {
        let defaultCurrency: String?
    }

    let settings: Settings
}

private struct SuccessResponse: Decodable {}

private struct DaysEnvelope: Decodable {
    let days: [TripDay]
}

private struct TripEnvelope: Decodable {
    let trip: Trip
}

private struct PlacePhoto: Decodable {
    let photoUrl: String?
}

private struct ReservationsEnvelope: Decodable {
    let reservations: [Reservation]
}

private struct StaysEnvelope: Decodable {
    let accommodations: [Stay]
}

private struct TripRoster: Decodable {
    let owner: TripMember
    let members: [TripMember]
}

private struct UserEnvelope: Decodable {
    struct User: Decodable {
        let id: Int
    }

    let user: User
}

private struct AppConfig: Decodable {
    let version: String?
}

private struct LoginRequest: Encodable {
    let email: String
    let password: String
    let rememberMe: Bool
}

private struct MfaRequest: Encodable {
    let mfaToken: String
    let code: String
    let rememberMe: Bool
}

private struct LoginResponse: Decodable {
    let token: String?
    let mfaRequired: Bool?
    let mfaToken: String?
}

private struct ErrorResponse: Decodable {
    let error: String
}

private struct TripList: Decodable {
    let trips: [Trip]
}

private struct BudgetItemList: Decodable {
    let items: [BudgetItem]
}

private struct BudgetItemEnvelope: Decodable {
    let item: BudgetItem
}

private struct PluginList: Decodable {
    struct Plugin: Decodable {
        let id: String
    }

    let plugins: [Plugin]
}

private struct AddonList: Decodable {
    struct Addon: Decodable {
        let id: String
        let enabled: Bool
    }

    let addons: [Addon]
}

private struct TodoList: Decodable {
    let items: [TodoItem]
}

private struct TodoEnvelope: Decodable {
    let item: TodoItem
}

private struct TodoCheck: Encodable {
    let checked: Bool
}

private struct RequestBody {
    let data: Data
    let contentType: String

    static func json(_ value: some Encodable) throws -> RequestBody {
        RequestBody(data: try TrekClient.encoder.encode(value), contentType: "application/json")
    }

    static func multipart(fields: [String: String], file: Data, fileName: String, mimeType: String) -> RequestBody {
        let boundary = "Boundary-\(UUID().uuidString)"
        var data = Data()
        for (name, value) in fields {
            data.append(Data("--\(boundary)\r\nContent-Disposition: form-data; name=\"\(name)\"\r\n\r\n\(value)\r\n".utf8))
        }
        data.append(Data("--\(boundary)\r\nContent-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\nContent-Type: \(mimeType)\r\n\r\n".utf8))
        data.append(file)
        data.append(Data("\r\n--\(boundary)--\r\n".utf8))
        return RequestBody(data: data, contentType: "multipart/form-data; boundary=\(boundary)")
    }
}
