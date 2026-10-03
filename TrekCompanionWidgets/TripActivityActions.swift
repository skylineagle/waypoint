import AppIntents
import SwiftUI
import WidgetKit

struct TripActivityActions: View {
    enum Action {
        case ticket(URL?)
        case directions(URL?)
        case done(Bool)
        case expense
    }

    var isCompact = false
    let buttons: [Action]

    private var visible: [Action] {
        buttons.filter { action in
            switch action {
            case .ticket(let url), .directions(let url): url != nil
            case .done(let isShown): isShown
            case .expense: true
            }
        }
    }

    private var isIconOnly: Bool { visible.count > 3 }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(visible.indices, id: \.self) { index in
                button(visible[index])
            }
        }
        .foregroundStyle(.white)
    }

    @ViewBuilder
    private func button(_ action: Action) -> some View {
        switch action {
        case .ticket(let url):
            if let url {
                Link(destination: url) { pill("Ticket", systemImage: "paperclip", isProminent: true) }
            }
        case .directions(let url):
            if let url {
                Link(destination: url) { pill("Go", systemImage: "location.fill") }
            }
        case .done(let isShown):
            if isShown {
                Button(intent: MarkNextStopDoneIntent()) { pill("Done", systemImage: "checkmark") }
                    .buttonStyle(.plain)
            }
        case .expense:
            Link(destination: WidgetLinks.addExpense) { pill("Expense", systemImage: "plus") }
        }
    }

    private func pill(_ title: String, systemImage: String, isProminent: Bool = false) -> some View {
        Label(title, systemImage: systemImage)
            .labelStyle(LabelVisibility(isIconOnly: isIconOnly))
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(isProminent ? .black : .white)
            .frame(maxWidth: .infinity, minHeight: isCompact ? 28 : 32)
            .background(isProminent ? AnyShapeStyle(.white) : AnyShapeStyle(.white.opacity(0.14)), in: .capsule)
    }
}
