import SwiftUI

struct RecapPlaceChooser: View {
    let candidates: [RecapCandidate]?
    let chosen: RecapCandidate?
    let onChoose: (RecapCandidate) -> Void
    let onSearch: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            if let candidates {
                ForEach(candidates) { candidate in
                    Button { onChoose(candidate) } label: { RecapCandidateRow(candidate: candidate, isChosen: candidate == chosen) }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                    Divider().overlay(Color.trekDivider)
                }
            } else {
                Label("Finding places nearby…", systemImage: "location.magnifyingglass")
                    .font(.poppins(14, relativeTo: .subheadline))
                    .foregroundStyle(Color.trekMuted)
                    .symbolEffect(.pulse)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                Divider().overlay(Color.trekDivider)
            }
            Button(action: onSearch) {
                Label("Search for a place", systemImage: "magnifyingglass")
                    .font(.poppins(15, .medium, relativeTo: .body))
                    .foregroundStyle(Color.trekMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .padding(12)
        }
        .background(Color.trekCard, in: .rect(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.trekBorder))
    }
}
