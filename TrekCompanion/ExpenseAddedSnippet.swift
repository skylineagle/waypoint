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
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(expense.totalPrice.money(expense.currency ?? ""))
                        .font(.title.bold())
                        .foregroundStyle(.primary)
                    Label("\(expense.name) · \(category.label)", systemImage: category.symbol)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Label("Added", systemImage: "checkmark")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.green)
            }
            HStack {
                Button(intent: UndoExpenseIntent(expenseID: expense.id, tripID: tripID)) {
                    Text("Undo").frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                Button(intent: OpenURLIntent(editURL)) {
                    Text("Edit").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.trekIndigo)
            }
            .font(.body.weight(.semibold))
            .controlSize(.large)
            .buttonBorderShape(.roundedRectangle(radius: 12))
        }
        .padding()
    }
}
