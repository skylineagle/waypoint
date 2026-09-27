import Foundation

struct Settlement: Decodable {
    struct Person: Decodable, Hashable {
        let userId: Int
        let username: String
    }

    struct Balance: Decodable, Identifiable {
        let userId: Int
        let username: String
        let balance: Double

        var id: Int { userId }
    }

    struct Flow: Decodable, Identifiable {
        let from: Person
        let to: Person
        let amount: Double

        var id: String { "\(from.userId)-\(to.userId)" }
    }

    struct FinalBudget: Decodable, Identifiable {
        let userId: Int
        let username: String
        let expenses: Double
        let reimbursed: Double
        let pending: Double
        let final: Double

        var id: Int { userId }
    }

    let balances: [Balance]
    let flows: [Flow]
    let finalBudgets: [FinalBudget]
}
