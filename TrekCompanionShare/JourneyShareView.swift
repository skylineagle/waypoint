import SwiftUI

struct JourneyShareView: View {
    let model: JourneyShareModel
    let onClose: () -> Void
    @State private var isChoosingJourney = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    if model.isSaved {
                        saved
                    } else {
                        if model.isLoading { ProgressView("Preparing photos…").frame(maxWidth: .infinity) }
                        ForEach(model.groups) { group in
                            ShareGroupCard(group: group, stops: model.stops(on: group.day)) { model.assign(group, to: $0) }
                        }
                        Text("DESTINATION").font(.poppins(11, .medium)).foregroundStyle(Color.trekMuted)
                        Button { isChoosingJourney = true } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(model.selection.selected?.title ?? "Choose a Journey")
                                        .font(.poppins(15, .semibold))
                                    Text("\(JourneySession.load()?.tripTitle ?? "No active trip") · Your active trip")
                                        .font(.poppins(12)).foregroundStyle(Color.trekMuted)
                                }
                                Spacer()
                                Image(systemName: "chevron.right").font(.footnote)
                            }
                            .padding(14)
                            .background(Color.trekInput, in: .rect(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.trekBorder, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .disabled(model.isLoading || JourneySession.load() == nil)
                        if model.unplacedCount > 0 {
                            Text("\(model.unplacedCount) without a stop will go to the gallery only.")
                                .font(.poppins(12)).foregroundStyle(Color.trekWarning)
                        }
                        if let error = model.errorMessage ?? model.selection.errorMessage {
                            Text(error).font(.poppins(13)).foregroundStyle(Color.trekDanger)
                        }
                        Button("Send all \(model.photoLabel)") { model.send() }
                            .buttonStyle(TrekButtonStyle())
                            .disabled(model.isLoading || model.isSending || model.files.isEmpty || model.errorMessage != nil || model.selection.selected == nil)
                        Text("You can write and organize them later in TREK.")
                            .font(.poppins(11)).foregroundStyle(Color.trekMuted)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(20)
            }
            .background(Color.trekCard)
            .navigationTitle("Send to Journey")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close", systemImage: "xmark", action: onClose).labelStyle(.iconOnly)
                        .disabled(model.isSending)
                }
            }
            .sheet(isPresented: $isChoosingJourney) {
                NavigationStack {
                    JourneyPickerView(selection: model.selection) {
                        isChoosingJourney = false
                        Task { await model.matchStops() }
                    }
                        .toolbar { Button("Close", systemImage: "xmark") { isChoosingJourney = false } }
                }
            }
        }
        .tint(.trekAccent)
    }

    private var saved: some View {
        VStack(spacing: 18) {
            Image(systemName: "checkmark.circle.fill").font(.system(size: 48)).foregroundStyle(Color.trekSuccess)
            Text("Photos saved on this phone").font(.poppins(20, .semibold)).multilineTextAlignment(.center)
            Text(model.uploadError ?? "They'll upload when a connection to TREK is available.")
                .font(.poppins(14)).foregroundStyle(Color.trekMuted).multilineTextAlignment(.center)
            if let destination = model.selection.selected {
                Text("\(model.photoLabel) → \(destination.title)")
                    .font(.poppins(14, .medium))
            }
            Text("Check progress in Waypoint → Settings → Journey uploads. Your photos are kept until TREK confirms the upload.")
                .font(.poppins(12)).foregroundStyle(Color.trekMuted)
            Button("Done", action: onClose).buttonStyle(TrekButtonStyle())
        }
        .padding(.top, 24)
    }
}
