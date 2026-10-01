import SwiftUI

struct ReminderKindRow<Destination: View>: View {
    let kind: ReminderKind
    let summary: String
    let onChange: () -> Void
    @ViewBuilder let destination: () -> Destination
    @AppStorage private var isEnabled: Bool

    init(kind: ReminderKind, summary: String, onChange: @escaping () -> Void, @ViewBuilder destination: @escaping () -> Destination) {
        self.kind = kind
        self.summary = summary
        self.onChange = onChange
        self.destination = destination
        _isEnabled = AppStorage(wrappedValue: true, kind.enabledKey, store: AppGroup.defaults)
    }

    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 12) {
                ReminderKindIcon(symbol: kind.symbol, tint: kind.tint)
                VStack(alignment: .leading, spacing: 2) {
                    Text(kind.title)
                    Text(summary).font(.caption).foregroundStyle(.secondary)
                }
                Spacer(minLength: 8)
                Toggle(kind.title, isOn: $isEnabled).labelsHidden()
            }
        }
        .onChange(of: isEnabled) { onChange() }
    }
}
