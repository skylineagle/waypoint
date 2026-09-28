import Foundation
import FoundationModels

enum ExpenseCategorizer {
    @Generable
    enum Choice: String, CaseIterable {
        case accommodation, food, groceries, transport, flights, activities, sightseeing
        case shopping, fees, health, tips, fuel, parking, other
    }

    private static let instructions = """
        You sort travel card payments into one spending category using only the merchant name. \
        Restaurants, cafes, bars and bakeries are food. Supermarkets and convenience stores \
        (7-Eleven, Lawson, FamilyMart) are groceries. Trains, metro, buses, taxis and IC card top-ups \
        are transport. Hotels and hostels are accommodation. Museums, temples, shrines and viewpoints \
        are sightseeing. Theme parks, tours and tickets are activities. Clothing, electronics, \
        department stores, souvenirs and malls (Uniqlo, Muji, Ginza Six, Bic Camera) are shopping. \
        Pharmacies and drugstores (Matsumoto Kiyoshi, Welcia) are health. Answer other when unsure.
        """

    static func category(for merchant: String) async -> CostCategory {
        let known = keywordGuess(for: merchant)
        if known != .other { return known }
        guard case .available = SystemLanguageModel.default.availability else {
            return keywordGuess(for: merchant)
        }
        do {
            let session = LanguageModelSession(instructions: instructions)
            let response = try await session.respond(to: "Merchant: \(merchant)", generating: Choice.self)
            return CostCategory(rawValue: response.content.rawValue) ?? .other
        } catch {
            return keywordGuess(for: merchant)
        }
    }

    static func keywordGuess(for merchant: String) -> CostCategory {
        let name = merchant.lowercased()
        let rules: [(CostCategory, [String])] = [
            (.groceries, ["7-eleven", "seven-eleven", "lawson", "familymart", "family mart", "supermarket", "aeon", "don quijote"]),
            (.transport, ["jr ", "metro", "railway", "suica", "pasmo", "taxi", "uber", "bus", "station", "line"]),
            (.accommodation, ["hotel", "hostel", "inn", "ryokan", "airbnb"]),
            (.food, ["restaurant", "cafe", "café", "coffee", "starbucks", "ramen", "sushi", "bar ", "izakaya", "bakery", "kitchen", "mcdonald"]),
            (.flights, ["airline", "airways", "el al", "ana ", "jal "]),
            (.fuel, ["eneos", "shell", "fuel", "petrol", "gas station"]),
            (.parking, ["parking"]),
            (.health, ["pharmacy", "drugstore", "clinic", "matsumoto kiyoshi", "welcia"]),
            (.shopping, ["uniqlo", "muji", "bic camera", "yodobashi", "loft", "tokyu hands"]),
        ]
        return rules.first { _, words in words.contains { name.contains($0) } }?.0 ?? .other
    }
}
