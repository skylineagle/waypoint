import SwiftUI

struct TripStepView: View {
    @Environment(AppModel.self) private var model
    let onContinue: () -> Void
    @State private var trips: [Trip]?
    @State private var selectedID: Int?
    @State private var errorMessage: String?

    private var selectedTrip: Trip? {
        trips?.first { $0.id == selectedID }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                StepHeader(title: "Which trip?", subtitle: "Payments are added to this trip's budget. You can switch any time.")

                VStack(spacing: 10) {
                    ForEach(trips ?? []) { trip in
                        Button {
                            selectedID = trip.id
                        } label: {
                            TripCard(trip: trip, isSelected: trip.id == selectedID)
                        }
                        .buttonStyle(.plain)
                    }
                }
                placeholder
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .refreshable { await load() }
        .task { await load() }
        .stepActions {
            Button("Continue") {
                model.select(selectedTrip)
                onContinue()
            }
            .buttonStyle(TrekButtonStyle())
            .disabled(selectedTrip == nil)
        }
    }

    @ViewBuilder
    private var placeholder: some View {
        if let errorMessage {
            Label(errorMessage, systemImage: "exclamationmark.circle")
                .font(.poppins(13, relativeTo: .footnote))
                .foregroundStyle(Color.trekDanger)
        } else if trips == nil {
            ProgressView().frame(maxWidth: .infinity)
        } else if trips?.isEmpty == true {
            Text("No trips yet. Create one in TREK first.")
                .font(.poppins(14))
                .foregroundStyle(Color.trekMuted)
        }
    }

    private func load() async {
        do {
            let loaded = try await TrekClient.current?.trips() ?? []
            trips = loaded
            errorMessage = nil
            selectedID = selectedID ?? model.account?.trip?.id ?? loaded.first(where: \.isHappeningNow)?.id ?? loaded.first?.id
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
