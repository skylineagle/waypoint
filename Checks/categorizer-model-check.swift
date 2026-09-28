import FoundationModels
enum Check {
    @Generable
    enum Choice: String, CaseIterable {
        case accommodation, food, groceries, transport, flights, activities, sightseeing
        case shopping, fees, health, tips, fuel, parking, other
    }

    static let instructions = """
        You sort travel card payments into one spending category using only the merchant name. \
        Restaurants, cafes, bars and bakeries are food. Supermarkets and convenience stores \
        (7-Eleven, Lawson, FamilyMart) are groceries. Trains, metro, buses, taxis and IC card top-ups \
        are transport. Hotels and hostels are accommodation. Museums, temples, shrines and viewpoints \
        are sightseeing. Theme parks, tours and tickets are activities. Clothing, electronics, \
        department stores, souvenirs and malls (Uniqlo, Muji, Ginza Six, Bic Camera) are shopping. \
        Pharmacies and drugstores (Matsumoto Kiyoshi, Welcia) are health. Answer other when unsure.
        """

}
for merchant in ["UNIQLO GINZA", "MATSUMOTO KIYOSHI", "GINZA SIX", "ICHIRAN SHIBUYA", "SENSOJI TEMPLE", "TOKYO METRO", "KIDDY LAND HARAJUKU", "TSUKIJI SUSHI SAY", "HOTEL GRACERY SHINJUKU", "SHIBUYA SKY"] {
    let session = LanguageModelSession(instructions: Check.instructions)
    let response = try await session.respond(to: "Merchant: \(merchant)", generating: Check.Choice.self)
    print(merchant, "->", response.content.rawValue)
}
