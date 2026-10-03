import SwiftUI

struct RecapView: View {
    @State private var model: RecapModel
    @Environment(\.dismiss) private var dismiss

    init(day: TripDay, dayNumber: Int) {
        _model = State(initialValue: RecapModel(day: day, dayNumber: dayNumber))
    }

    var body: some View {
        content
            .background(Color.trekBackground)
            .task { await model.load() }
            .interactiveDismissDisabled()
    }

    @ViewBuilder
    private var content: some View {
        switch model.phase {
        case .loading:
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed(let message):
            ContentUnavailableView {
                Label("Can't recap this day", systemImage: "photo.badge.exclamationmark")
            } description: {
                Text(message)
            } actions: {
                Button("Close") { dismiss() }
            }
        case .reviewing, .publishing:
            stepper
        case .done(let summary):
            RecapDoneView(dayNumber: model.dayNumber, summary: summary) { dismiss() }
        }
    }

    private var isPublishing: Bool {
        if case .publishing = model.phase { true } else { false }
    }

    private var nextPlaceName: String? {
        model.isLast ? nil : model.places[model.index + 1].stop.place.name
    }

    private var stepper: some View {
        VStack(spacing: 0) {
            OnboardingProgressHeader(stepNumber: model.index + 1, total: model.places.count) {
                if model.index == 0 { dismiss() } else { model.back() }
            }
            RecapPlaceStep(model: model)
                .id(model.index)
                .transition(.push(from: .trailing))
            if let nextPlaceName {
                Text("Up next: \(nextPlaceName)")
                    .font(.poppins(13, .medium, relativeTo: .footnote))
                    .foregroundStyle(Color.trekMuted)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
            }
            HStack(spacing: 10) {
                Button("Skip") { advance(skipping: true) }
                    .buttonStyle(TrekButtonStyle(kind: .secondary))
                    .frame(maxWidth: 110)
                Button(action: { advance(skipping: false) }) {
                    if isPublishing { ProgressView() } else { Text(model.isLast ? "Add to Journey" : "Next") }
                }
                .buttonStyle(TrekButtonStyle())
            }
            .disabled(isPublishing)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .animation(.smooth, value: model.index)
    }

    private func advance(skipping: Bool) {
        Task { await model.next(skipping: skipping) }
    }
}
