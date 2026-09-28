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

    private var tripDay: TripDay? {
        guard tab == .today, case .during(let day, _) = today.phase, !day.stops.isEmpty else { return nil }
        return day
    }

    var body: some View {
        @Bindable var app = app
        TabView(selection: $tab.animation(.smooth)) {
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
        .tabViewBottomAccessory(isEnabled: tripDay != nil) {
            if let tripDay { TripStopAccessory(model: today, day: tripDay) }
        }
        .task { await costs.load() }
        .sheet(isPresented: $app.isAddingExpense) {
            ExpenseEditorView(
                item: nil,
                converter: costs.converter,
                members: costs.members,
                meID: costs.meID,
                onSave: { try await costs.save($0, editing: nil, receipt: $1) },
                onDelete: {}
            )
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $app.isConverting) {
            ConverterSheet(converter: costs.converter, amount: app.converterAmount)
        }
    }
}

enum MainTab: Hashable {
    case today, costs, settings
}
