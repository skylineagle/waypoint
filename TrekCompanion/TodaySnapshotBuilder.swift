import Foundation

enum TodaySnapshotBuilder {
    static func make(today: TodayModel, costs: CostsModel) -> TodaySnapshot? {
        let currency = costs.converter.displayCurrency
        let spent = costs.todayTotal.money(currency, fractionDigits: 0...0)
        let average = costs.hasStarted ? costs.dailyAverage.money(currency, fractionDigits: 0...0) : nil
        switch today.phase {
        case .during(let day, let number):
            return TodaySnapshot(
                tripID: today.trip.id,
                tripTitle: today.trip.title,
                dayLabel: "Day \(number) of \(today.days?.count ?? number)",
                dayTitle: day.title ?? "Day \(number)",
                date: day.date ?? ExpenseDate.today,
                stops: stops(of: day, legs: today.legs, trip: today.trip),
                spentToday: spent,
                dailyAverage: average,
                countdown: nil
            )
        case .before(let daysUntil, let firstDay):
            return TodaySnapshot(
                tripID: today.trip.id,
                tripTitle: today.trip.title,
                dayLabel: "Starts in",
                dayTitle: today.trip.title,
                date: firstDay?.date ?? today.trip.startDate ?? ExpenseDate.today,
                stops: [],
                spentToday: spent,
                dailyAverage: nil,
                countdown: daysUntil == 1 ? "Tomorrow" : "\(daysUntil) days",
                coverPhotoName: WidgetPhotos.coverName(for: today.trip)
            )
        case .after:
            return nil
        }
    }

    private static func stops(of day: TripDay, legs: [Int: TravelLeg], trip: Trip) -> [TodaySnapshot.Stop] {
        day.stops.map { stop in
            var legText: String?
            if let leg = legs[stop.id] {
                legText = leg.isTransit ? "\(leg.minutes) min by transit" : "\(leg.minutes) min walk"
            }
            return TodaySnapshot.Stop(
                id: stop.id,
                name: stop.place.name,
                latitude: stop.place.lat,
                longitude: stop.place.lng,
                leg: legText,
                photoName: WidgetPhotos.name(for: stop.place, trip: trip)
            )
        }
    }
}
