import FoundationModels

enum RecapWriter {
    static let instructions = """
        You draft a short first-person travel journal note that the traveller will edit. \
        Write one or two plain, simple sentences using only the facts given. \
        Never describe sights, sounds, feelings, food, weather or people that are not in the facts. \
        Never mention times or dates. No hashtags, no emoji.
        """

    static var isAvailable: Bool {
        if case .available = SystemLanguageModel.default.availability { true } else { false }
    }

    static func draft(place: String, notes: String?) async -> String {
        guard isAvailable else { return "" }
        let facts = ["Place: \(place)", notes.map { "Plan notes: \($0)" }].compactMap(\.self).joined(separator: "\n")
        let response = try? await LanguageModelSession(instructions: instructions).respond(to: facts)
        return response?.content.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
}
