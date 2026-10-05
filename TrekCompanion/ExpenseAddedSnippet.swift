import AppIntents
import SwiftUI

struct ExpenseAddedSnippet: View {
    let expense: BudgetItem
    let tripID: Int
    let category: CostCategory

    private var editURL: URL {
        URL(string: "trekcompanion://edit-expense?id=\(expense.id)")!
    }

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: category.symbol)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(category.color)
                    .frame(width: 40, height: 40)
                    .background(category.color.opacity(0.15), in: .circle)
                VStack(alignment: .leading, spacing: 1) {
                    Text(expense.name)
                        .font(.headline)
                        .lineLimit(1)
                    Text(category.label)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 8)
                Text(expense.totalPrice.money(expense.currency ?? ""))
                    .font(.title3.weight(.semibold))
                    .monospacedDigit()
            }
            HStack(spacing: 10) {
                Button(intent: UndoExpenseIntent(expenseID: expense.id, tripID: tripID)) {
                    Label("Undo", systemImage: "arrow.uturn.backward").frame(maxWidth: .infinity)
                }
                Button(intent: OpenURLIntent(editURL)) {
                    Label("Edit", systemImage: "pencil").frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
            .font(.subheadline.weight(.semibold))
            .tint(.primary)
        }
        .padding()
    }
}
