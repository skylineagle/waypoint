import SwiftUI

enum ExpenseEditorTarget: Identifiable {
    case new
    case scan
    case edit(BudgetItem)

    var id: Int {
        switch self {
        case .new: -1
        case .scan: -2
        case .edit(let item): item.id
        }
    }

    var startsScanning: Bool {
        if case .scan = self { true } else { false }
    }

    var item: BudgetItem? {
        if case .edit(let item) = self { item } else { nil }
    }
}

struct CostsView: View {
    let model: CostsModel
    @State private var tab = CostsTab.expenses
    @State private var categoryFilter: CostCategory?
    @State private var unpaidOnly = false
    @State private var editor: ExpenseEditorTarget?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    CostsHeader(trip: model.trip).plainListRow()
                    CostsTotalCard(model: model, onShowUnpaid: showUnpaid)
                        .redacted(reason: model.items == nil ? .placeholder : [])
                        .plainListRow()
                    CostsTabPicker(selection: $tab, tabs: tabs).plainListRow()
                }

                switch tab {
                case .expenses:
                    expenseSections
                case .insights:
                    Section {
                        CostsInsightsView(model: model) { category in
                            categoryFilter = category
                            tab = .expenses
                        }
                        .plainListRow()
                    }
                case .balances:
                    Section {
                        BalancesView(model: model).plainListRow()
                    }
                }
            }
            .listStyle(.insetGrouped)
            .listSectionSpacing(10)
            .scrollContentBackground(.hidden)
            .background(Color.trekBackground)
            .toolbarVisibility(.hidden, for: .navigationBar)
            .contentMargins(.bottom, 72, for: .scrollContent)
            .overlay(alignment: .bottomTrailing) { addButton }
            .refreshable { await model.load() }
            .sheet(item: $editor) { target in
                ExpenseEditorView(
                    item: target.item,
                    converter: model.converter,
                    members: model.members,
                    meID: model.meID,
                    startsScanning: target.startsScanning,
                    onSave: { try await model.save($0, editing: target.item, receipt: $1) },
                    onDelete: { if let item = target.item { await model.delete(item) } }
                )
                .presentationDragIndicator(.visible)
            }
            .onChange(of: model.unpaidItems.isEmpty) { _, isEmpty in
                if isEmpty { unpaidOnly = false }
            }
        }
    }

    private var tabs: [CostsTab] {
        model.isShared ? CostsTab.allCases : [.expenses, .insights]
    }

    @ViewBuilder
    private var expenseSections: some View {
        let categories = model.categoryTotals.map(\.category)
        if unpaidOnly {
            Section {
                Button {
                    unpaidOnly = false
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill").foregroundStyle(Color.trekWarning)
                        Text("Expenses without a payer — tap one to set who paid")
                            .foregroundStyle(Color.trekTextSecondary)
                        Spacer(minLength: 6)
                        Text("Show all").fontWeight(.semibold).foregroundStyle(Color.trekText)
                    }
                    .font(.poppins(12.5, relativeTo: .footnote))
                    .contentShape(.rect)
                }
                .buttonStyle(.borderless)
                .plainListRow()
            }
        } else if categories.count > 1 {
            Section {
                CategoryFilterChips(categories: categories, selection: $categoryFilter)
                    .plainListRow()
            }
        }

        if let errorMessage = model.errorMessage {
            Section {
                Label(errorMessage, systemImage: "wifi.exclamationmark")
                    .font(.poppins(13, relativeTo: .footnote))
                    .foregroundStyle(Color.trekDanger)
            }
        } else if model.items == nil {
            Section {
                ProgressView().frame(maxWidth: .infinity, minHeight: 80)
            }
            .listRowBackground(Color.clear)
        } else if model.items?.isEmpty == true {
            Section {
                ContentUnavailableView("No costs yet", systemImage: "creditcard", description: Text("Pay with Apple Pay or tap + to add one."))
            }
            .listRowBackground(Color.clear)
        }

        ForEach(model.days(in: categoryFilter, unpaidOnly: unpaidOnly)) { day in
            Section {
                ForEach(day.items) { item in
                    Button {
                        editor = .edit(item)
                    } label: {
                        ExpenseRow(item: item, converter: model.converter)
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(Color.trekCard)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            Task { await model.delete(item) }
                        }
                        .tint(Color.trekDanger)
                        Button("Edit", systemImage: "pencil") { editor = .edit(item) }
                            .tint(Color(hex: 0x111827))
                    }
                    .contextMenu {
                        Button("Edit", systemImage: "pencil") { editor = .edit(item) }
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            Task { await model.delete(item) }
                        }
                    }
                }
            } header: {
                ExpenseDayHeader(day: day, currency: model.converter.displayCurrency)
            }
        }
    }

    private func showUnpaid() {
        let unpaid = model.unpaidItems
        if unpaid.count == 1, let item = unpaid.first {
            editor = .edit(item)
            return
        }
        categoryFilter = nil
        unpaidOnly = true
        tab = .expenses
    }

    private var addButton: some View {
        Group {
            if ReceiptParser.isAvailable {
                Menu {
                    Button("Add manually", systemImage: "square.and.pencil") { editor = .new }
                    Button(DocumentScanner.isAvailable ? "Scan receipt" : "Receipt from photos", systemImage: "doc.text.viewfinder") { editor = .scan }
                } label: {
                    plusIcon
                }
            } else {
                Button { editor = .new } label: { plusIcon }
            }
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .controlSize(.regular)
        .tint(Color.trekAccent)
        .accessibilityLabel("Add expense")
        .padding(.trailing, 16)
        .padding(.bottom, 12)
    }

    private var plusIcon: some View {
        Image(systemName: "plus")
            .font(.system(size: 18, weight: .semibold))
            .frame(width: 28, height: 28)
    }
}
