import SwiftUI

struct BeforeTripView: View {
    let model: TodayModel
    let daysUntil: Int
    let firstDay: TripDay?

    private var countdown: String {
        daysUntil == 1 ? "Tomorrow" : "\(daysUntil) days"
    }

    private var summary: String {
        let bookings = model.reservations.filter { $0.type != "hotel" }.count
        return "\(model.days?.count ?? 0) days · \(model.stays.count) hotels · \(bookings) bookings"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 1) {
                    CardCaption(text: "Your next trip")
                    Text(model.trip.title)
                        .font(.poppins(26, .bold, relativeTo: .largeTitle))
                        .foregroundStyle(Color.trekText)
                        .accessibilityAddTraits(.isHeader)
                }
                Spacer()
                if let range = model.trip.dateRange {
                    Label(range, systemImage: "calendar")
                        .font(.poppins(12.5, .semibold, relativeTo: .footnote))
                        .foregroundStyle(Color.trekText)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .glassEffect()
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("STARTS IN")
                    .font(.poppins(10, .bold, relativeTo: .caption2))
                    .tracking(0.9)
                    .foregroundStyle(.white.opacity(0.55))
                Text(countdown)
                    .font(.museoModerno(48))
                    .contentTransition(.numericText())
                Text(summary)
                    .font(.poppins(12, relativeTo: .caption))
                    .foregroundStyle(.white.opacity(0.62))
            }
            .foregroundStyle(Color(hex: 0xF5F5F7))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
                LinearGradient(colors: [.trekHeroTop, .trekHeroBottom], startPoint: .topLeading, endPoint: .bottomTrailing),
                in: .rect(cornerRadius: 20)
            )
            .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color.trekHeroEdge))
            .accessibilityElement(children: .combine)

            if let firstDay {
                let bookings = model.bookings(on: firstDay)
                if !bookings.isEmpty || !firstDay.stops.isEmpty {
                    CardCaption(text: dayTitle(firstDay)).padding(.top, 6)
                    ForEach(bookings) { BookingRow(reservation: $0) }
                    ForEach(firstDay.stops) { stop in
                        StopRow(stop: stop, number: (firstDay.stops.firstIndex(of: stop) ?? 0) + 1, state: .upcoming) {}
                    }
                }
                if let firstStay = model.stays.first {
                    StayCard(caption: "First nights", stay: firstStay).padding(.top, 6)
                }
            }
        }
    }

    private func dayTitle(_ day: TripDay) -> String {
        guard let date = ExpenseDate.date(from: day.date) else { return "Day 1" }
        return "Day 1 · \(date.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated)))"
    }
}
