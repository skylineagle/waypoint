import SwiftUI

struct RecapCandidateRow: View {
    let candidate: RecapCandidate
    let isChosen: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isChosen ? "largecircle.fill.circle" : "circle")
                .font(.system(size: 18))
                .foregroundStyle(isChosen ? Color.trekAccent : Color.trekFaint)
            VStack(alignment: .leading, spacing: 1) {
                Text(candidate.name)
                    .font(.poppins(15, .medium, relativeTo: .body))
                    .foregroundStyle(Color.trekText)
                Text(candidate.detail)
                    .font(.poppins(12, relativeTo: .caption))
                    .foregroundStyle(Color.trekMuted)
            }
            Spacer(minLength: 0)
        }
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isChosen ? .isSelected : [])
    }
}
