import SwiftUI

enum ListKind: String, CaseIterable, Identifiable {
    case todo = "To-Do"
    case packing = "Packing list"

    var id: Self { self }
}

struct ListsView: View {
    let todos: TodosModel
    let packing: PackingModel
    let members: [TripMember]
    let meID: Int?
    @AppStorage("listsKind") private var kind = ListKind.todo

    private var subtitle: String {
        switch kind {
        case .packing: "\(packing.trip.title) · \(packing.packedCount)/\(packing.totalCount) packed"
        case .todo: "\(todos.trip.title) · \(todos.openCount) open · \(todos.doneCount) done"
        }
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                header.padding(.horizontal, 20)
                switch kind {
                case .packing: PackingView(model: packing)
                case .todo: TodosView(model: todos, members: members, meID: meID)
                }
            }
            .background(Color.trekBackground)
            .toolbarVisibility(.hidden, for: .navigationBar)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Lists")
                    .font(.poppins(26, .bold, relativeTo: .largeTitle))
                    .foregroundStyle(Color.trekText)
                Text(subtitle)
                    .font(.poppins(13, relativeTo: .subheadline))
                    .foregroundStyle(Color.trekMuted)
                    .contentTransition(.numericText())
            }
            Picker("List", selection: $kind.animation(.smooth)) {
                Text("To-Do \(todos.items?.count ?? 0)").tag(ListKind.todo)
                Text("Packing \(packing.totalCount)").tag(ListKind.packing)
            }
            .pickerStyle(.segmented)
            if kind == .packing {
                PackingProgressBar(packed: packing.packedCount, total: packing.totalCount)
                    .padding(.top, 2)
            }
        }
        .padding(.top, 8)
    }
}
