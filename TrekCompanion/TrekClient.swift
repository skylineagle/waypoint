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
        guard let (data, status) = try? await send("GET", "api/auth/app-config", serverURL: serverURL, token: nil, body: nil as LoginRequest?),
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

    func defaultCurrency() async throws -> String? {
        try await request("GET", "api/settings", as: SettingsEnvelope.self).settings.defaultCurrency
    }

    func currentUserID() async throws -> Int {
        try await request("GET", "api/auth/me", as: UserEnvelope.self).user.id
    }

    func days(tripID: Int) async throws -> [TripDay] {
        try await request("GET", "api/trips/\(tripID)/days", as: DaysEnvelope.self).days
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
        try await request("POST", "api/trips/\(tripID)/budget", body: input, as: BudgetItemEnvelope.self).item
    }

    func updateExpense(id: Int, _ input: ExpenseInput, tripID: Int) async throws -> BudgetItem {
        try await request("PUT", "api/trips/\(tripID)/budget/\(id)", body: input, as: BudgetItemEnvelope.self).item
    }

    func deleteExpense(id: Int, tripID: Int) async throws {
        _ = try await request("DELETE", "api/trips/\(tripID)/budget/\(id)", as: SuccessResponse.self)
    }

    private func request<Response: Decodable>(
        _ method: String,
        _ path: String,
        body: ExpenseInput? = nil,
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
            throw TrekError("Your Trek session expired. Open Trek Companion to sign in again.")
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
        let (data, status) = try await send("POST", path, serverURL: serverURL, token: nil, body: body)
        try validate(data: data, status: status)
        return try decoder.decode(Response.self, from: data)
    }

    private static func send(
        _ method: String,
        _ path: String,
        serverURL: URL,
        token: String?,
        body: (some Encodable)?
    ) async throws -> (Data, Int) {
        let parts = path.split(separator: "?", maxSplits: 1).map(String.init)
        var url = serverURL.appending(path: parts[0])
        if parts.count == 2 {
            url = URL(string: "\(url.absoluteString)?\(parts[1])") ?? url
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpShouldHandleCookies = false
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token {
            request.setValue("\(sessionCookie)=\(token)", forHTTPHeaderField: "Cookie")
        }
        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try encoder.encode(body)
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

    private static let encoder: JSONEncoder = {
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
