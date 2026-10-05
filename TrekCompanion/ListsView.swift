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
            Group {
                switch kind {
                case .packing: PackingView(model: packing)
                case .todo: TodosView(model: todos, members: members, meID: meID)
                }
            }
            .safeAreaBar(edge: .top, spacing: 0) {
                header.padding(.horizontal, 20)
            }
            .background(Color.trekBackground)
            .navigationTitle("Lists")
            .navigationSubtitle(subtitle)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
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
        .padding(.bottom, 8)
    }
}
