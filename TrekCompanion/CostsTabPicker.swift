import SwiftUI

enum CostsTab: String, CaseIterable {
    case expenses = "Expenses"
    case insights = "Insights"
    case balances = "Balances"
}

struct CostsTabPicker: View {
    @Binding var selection: CostsTab
    let tabs: [CostsTab]

    var body: some View {
        Picker("View", selection: $selection) {
            ForEach(tabs, id: \.self) { tab in
                Text(tab.rawValue).tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .controlSize(.small)
    }
}
