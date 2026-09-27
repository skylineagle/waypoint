import SwiftUI

struct ExpenseSplitSection: View {
    let members: [TripMember]
    let meID: Int?
    let perPerson: String?
    @Binding var payerID: Int?
    @Binding var splitIDs: Set<Int>

    private func name(of member: TripMember) -> String {
        member.id == meID ? "You" : member.username
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            CardCaption(text: "Paid by")
            ScrollView(.horizontal) {
                HStack(spacing: 6) {
                    ForEach(members) { member in
                        MemberChip(userID: member.id, name: name(of: member), isSelected: payerID == member.id) {
                            payerID = member.id
                        }
                    }
                    MemberChip(userID: nil, name: "Nobody yet", isSelected: payerID == nil) {
                        payerID = nil
                    }
                }
            }
            .scrollIndicators(.hidden)

            HStack {
                CardCaption(text: "Split between")
                Spacer()
                if let perPerson, !splitIDs.isEmpty {
                    Text("\(perPerson) each")
                        .font(.poppins(11, relativeTo: .caption2))
                        .foregroundStyle(Color.trekMuted)
                }
            }
            .padding(.top, 6)
            ScrollView(.horizontal) {
                HStack(spacing: 6) {
                    ForEach(members) { member in
                        MemberChip(userID: member.id, name: name(of: member), isSelected: splitIDs.contains(member.id)) {
                            if splitIDs.contains(member.id) {
                                splitIDs.remove(member.id)
                            } else {
                                splitIDs.insert(member.id)
                            }
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            if splitIDs.isEmpty {
                Text("Not split — kept as a planning cost.")
                    .font(.poppins(11, relativeTo: .caption2))
                    .foregroundStyle(Color.trekMuted)
            }
        }
        .padding(.top, 8)
    }
}
