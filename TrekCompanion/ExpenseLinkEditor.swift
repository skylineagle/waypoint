import SwiftUI

struct ExpenseLinkEditor: View {
    let link: ExpenseLink
    let costs: CostsModel
    @State private var hasReloaded = false

    private var item: BudgetItem? {
        costs.items?.first { $0.id == link.id }
    }

    var body: some View {
        if let item {
            ExpenseEditorView(
                item: item,
                converter: costs.converter,
                members: costs.members,
                meID: costs.meID,
                onSave: { try await costs.save($0, editing: item, receipt: $1) },
                onDelete: { await costs.delete(item) }
            )
        } else if hasReloaded {
            ContentUnavailableView("Expense not found", systemImage: "creditcard", description: Text("It may have been removed."))
        } else {
            ProgressView()
                .task {
                    await costs.load()
                    hasReloaded = true
                }
        }
    }
}
