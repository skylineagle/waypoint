import SwiftUI

struct JourneyPickerView: View {
    let selection: JourneySelection
    let onSelect: () -> Void
    @State private var selectedID: Int?
    @State private var isConfirmingCreation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("For your active trip, \(JourneySession.load()?.tripTitle ?? "your trip"). Waypoint will remember your choice for this trip.")
                    .font(.poppins(14))
                    .foregroundStyle(Color.trekMuted)
                ForEach(selection.destinations) { destination in
                    Button {
                        selectedID = destination.id
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.title2)
                                .foregroundStyle(Color.trekViolet)
                            Text(destination.title).font(.poppins(15, .semibold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            if selectedID == destination.id { Image(systemName: "checkmark.circle.fill") }
                        }
                        .padding(16)
                        .background(Color.trekInput, in: .rect(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(selectedID == destination.id ? .isSelected : [])
                }
                if let error = selection.errorMessage {
                    Text(error).font(.poppins(13)).foregroundStyle(Color.trekDanger)
                    Button("Try again") { Task { await selection.load() } }
                        .buttonStyle(TrekButtonStyle(kind: .secondary))
                } else if selection.hasLoaded, selection.destinations.isEmpty {
                    Text("There isn't a Journey you can add photos to linked to this trip.")
                        .font(.poppins(14)).foregroundStyle(Color.trekMuted)
                    Button("Create a Journey") { isConfirmingCreation = true }
                        .buttonStyle(TrekButtonStyle())
                }
                if selection.isLoading { ProgressView().frame(maxWidth: .infinity) }
                if let destination = selection.destinations.first(where: { $0.id == selectedID }) {
                    Button("Use \(destination.title)") {
                        selection.select(destination)
                        onSelect()
                    }
                    .buttonStyle(TrekButtonStyle())
                }
            }
            .padding(20)
        }
        .background(Color.trekBackground)
        .navigationTitle("Choose a Journey")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await selection.load()
            selectedID = selection.selected?.id
        }
        .confirmationDialog("Create a Journey for \(JourneySession.load()?.tripTitle ?? "this trip")?", isPresented: $isConfirmingCreation, titleVisibility: .visible) {
            Button("Create Journey") {
                Task {
                    await selection.create()
                    selectedID = selection.selected?.id
                    if selection.errorMessage == nil { onSelect() }
                }
            }
        } message: {
            Text("This creates a Journey in TREK and links it to your active trip.")
        }
    }
}
