import SwiftUI

struct MainTabView: View {
    @Environment(AppModel.self) private var app
    @State private var today: TodayModel
    @State private var costs: CostsModel
    @State private var todos: TodosModel
    @State private var packing: PackingModel

    init(trip: Trip) {
        _today = State(initialValue: TodayModel(trip: trip))
        _costs = State(initialValue: CostsModel(trip: trip))
        _todos = State(initialValue: TodosModel(trip: trip))
        _packing = State(initialValue: PackingModel(trip: trip))
    }

    private var tripDay: TripDay? {
        guard app.tab != .settings, app.tab != .today || (today.selectedDayID == nil && !today.isMapShown), case .during(let day, _) = today.phase, !day.stops.isEmpty else { return nil }
        return day
    }

    private var recapDay: Binding<TripDay?> {
        Binding { today.days?.first { $0.id == app.recapDayID } } set: { app.recapDayID = $0?.id }
    }

    var body: some View {
        @Bindable var app = app
        TabView(selection: $app.tab.animation(.smooth)) {
            Tab("Itinerary", systemImage: "point.bottomleft.forward.to.point.topright.scurvepath", value: MainTab.today) {
                TodayView(model: today, costs: costs)
            }
            Tab("Costs", systemImage: "creditcard", value: MainTab.costs) {
                CostsView(model: costs)
            }
            if todos.isAvailable {
                Tab("Lists", systemImage: "checklist", value: MainTab.todos) {
                    ListsView(todos: todos, packing: packing, members: costs.members, meID: costs.meID)
                }
            }
            Tab("Settings", systemImage: "gearshape", value: MainTab.settings) {
                SettingsView()
            }
        }
        .tabViewBottomAccessory(isEnabled: tripDay != nil) {
            if let tripDay {
                TripStopAccessory(model: today, day: tripDay) {
                    today.selectedDayID = nil
                    app.tab = .today
                }
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .task { await costs.load() }
        .task { await todos.load() }
        .environment(todos)
        .environment(today)
        .bookingFilesPreview(model: today)
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
        .sheet(isPresented: $app.isScanningReceipt) {
            ExpenseEditorView(
                item: nil,
                converter: costs.converter,
                members: costs.members,
                meID: costs.meID,
                startsScanning: true,
                onSave: { try await costs.save($0, editing: nil, receipt: $1) },
                onDelete: {}
            )
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $app.editingExpense) { link in
            ExpenseLinkEditor(link: link, costs: costs)
                .presentationDragIndicator(.visible)
        }
        .fullScreenCover(item: recapDay) { day in
            RecapView(day: day, dayNumber: today.number(of: day))
        }
        .sheet(isPresented: $app.isConverting) {
            ConverterSheet(converter: costs.converter, amount: app.converterAmount)
        }
    }
}

enum MainTab: String, Hashable {
    case today, costs, todos, settings

    init?(link: URL) {
        guard link.scheme == "trekcompanion", let tab = MainTab(rawValue: link.host() ?? "") else { return nil }
        self = tab
    }
}
