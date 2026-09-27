import SwiftUI

struct MainTabView: View {
    @Environment(AppModel.self) private var app
    @State private var tab = MainTab.today
    @State private var today: TodayModel
    @State private var costs: CostsModel

    init(trip: Trip) {
        _today = State(initialValue: TodayModel(trip: trip))
        _costs = State(initialValue: CostsModel(trip: trip))
    }

    var body: some View {
        @Bindable var app = app
        TabView(selection: $tab) {
            Tab("Today", systemImage: "sun.max", value: MainTab.today) {
                TodayView(model: today, costs: costs)
            }
            Tab("Costs", systemImage: "creditcard", value: MainTab.costs) {
                CostsView(model: costs)
            }
            Tab("Settings", systemImage: "gearshape", value: MainTab.settings) {
                SettingsView()
            }
        }
        .task { await costs.load() }
        .sheet(isPresented: $app.isAddingExpense) {
            ExpenseEditorView(
                item: nil,
                converter: costs.converter,
                members: costs.members,
                meID: costs.meID,
                onSave: { try await costs.save($0, editing: nil) },
                onDelete: {}
            )
            .presentationDragIndicator(.visible)
        }
    }
}

enum MainTab: Hashable {
    case today, costs, settings
}
