import SwiftUI

struct JourneyShareView: View {
    @Bindable var model: JourneyShareModel
    let onClose: () -> Void
    @State private var isChoosingJourney = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    if model.isSaved {
                        saved
                    } else {
                        if model.isLoading {
                            ShareProcessingStrip(queue: model.queue, processedCount: model.processedCount)
                        }
                        if !model.receipts.isEmpty {
                            Text("\(model.receipts.count) \(model.receipts.count == 1 ? "RECEIPT" : "RECEIPTS") · ADD AS EXPENSES")
                                .font(.poppins(11, .medium)).foregroundStyle(Color.trekMuted)
                            ForEach($model.receipts) { $receipt in
                                ShareReceiptRow(receipt: $receipt, fallbackCurrency: model.tripCurrency)
                            }
                            Text("Turn a receipt off to send it to Journey instead.")
                                .font(.poppins(12)).foregroundStyle(Color.trekMuted)
                        }
                        if !model.files.isEmpty && !model.receipts.isEmpty {
                            Text("\(model.photoLabel.uppercased()) · JOURNEY")
                                .font(.poppins(11, .medium)).foregroundStyle(Color.trekMuted)
                        }
                        ForEach(model.groups) { group in
                            ShareGroupCard(group: group, stops: model.stops(on: group.day)) { model.assign(group, to: $0) }
                        }
                        if !model.outsideTripPhotos.isEmpty {
                            OutsideTripNote(files: model.outsideTripPhotos.map(\.file))
                        }
                        if !model.files.isEmpty {
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
                        }
                        if let error = model.errorMessage ?? model.selection.errorMessage {
                            Text(error).font(.poppins(13)).foregroundStyle(Color.trekDanger)
                        }
                        Button(model.isLoading ? "Reading photos…" : model.receipts.isEmpty && !model.files.isEmpty ? "Send all \(model.photoLabel)" : model.sendLabel) { Task { await model.send() } }
                            .buttonStyle(TrekButtonStyle())
                            .disabled(!model.canSend)
                        Text("You can write and organize them later in TREK.")
                            .font(.poppins(11)).foregroundStyle(Color.trekMuted)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(20)
            }
            .background(Color.trekCard)
            .navigationTitle(model.receipts.isEmpty ? "Send to Journey" : "Send to Waypoint")
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
        VStack(spacing: 14) {
            Image(systemName: "checkmark.circle.fill").font(.system(size: 64)).foregroundStyle(Color.trekSuccess)
                .padding(.top, 60)
            Text("Done").font(.poppins(22, .semibold))
            HStack(spacing: 12) {
                if model.addedExpenseCount > 0 {
                    Label("\(model.addedExpenseCount) \(model.addedExpenseCount == 1 ? "expense" : "expenses")", systemImage: "creditcard")
                }
                if !model.files.isEmpty {
                    Label("\(model.photoLabel) → \(model.selection.selected?.title ?? "Journey")", systemImage: "photo")
                }
            }
            .font(.poppins(14)).foregroundStyle(Color.trekMuted)
            if let uploadError = model.uploadError {
                Text(uploadError).font(.poppins(13)).foregroundStyle(Color.trekWarning).multilineTextAlignment(.center)
            }
            Button("Done", action: onClose).buttonStyle(TrekButtonStyle()).padding(.top, 40)
        }
        .frame(maxWidth: .infinity)
    }
}
