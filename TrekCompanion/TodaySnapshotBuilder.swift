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
                stops: stops(of: day, today: today),
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

    private static func stops(of day: TripDay, today: TodayModel) -> [TodaySnapshot.Stop] {
        let bookings = today.dayBookings(on: day)
        return day.stops.map { stop in
            let leg = today.legs[stop.id]
            let booking = bookings.stopBookings[stop.id] ?? today.reservations.first { $0.type == "hotel" && $0.accommodationPlaceId == stop.place.id }
            let bookedAt = booking?.startDate ?? stop.assignmentTime.flatMap { TripReminderEvents.moment(day.date, time: $0) }
            return TodaySnapshot.Stop(
                id: stop.id,
                name: stop.place.name,
                latitude: stop.place.lat,
                longitude: stop.place.lng,
                leg: leg.map { $0.isTransit ? "\($0.minutes) min by transit" : "\($0.minutes) min walk" },
                photoName: WidgetPhotos.name(for: stop.place, trip: today.trip),
                category: stop.place.category,
                bookedAt: bookedAt,
                leaveBy: leaveBy(bookedAt, leg: leg),
                journey: bookings.journeys[stop.id].flatMap { journey(of: $0, today: today) },
                ticketURL: booking.flatMap { ticketURL(of: $0, today: today) }
            )
        }
    }

    private static func journey(of reservation: Reservation, today: TodayModel) -> TripJourney? {
        guard let departs = reservation.startDate else { return nil }
        return TripJourney(
            title: reservation.title,
            symbol: reservation.symbol,
            from: reservation.departure?.name,
            to: reservation.arrival?.name,
            departs: departs,
            arrives: reservation.endDate,
            confirmation: reservation.confirmationNumber,
            leaveBy: leaveBy(departs, leg: today.stationLegs[reservation.id]),
            ticketURL: ticketURL(of: reservation, today: today),
            directionsURL: reservation.departure.map { AppSettings.directionsLink(latitude: $0.lat, longitude: $0.lng) }
        )
    }

    private static func leaveBy(_ date: Date?, leg: TravelLeg?) -> Date? {
        guard let date, let leg else { return nil }
        return date.addingTimeInterval(-Double(leg.minutes) * 60)
    }

    private static func ticketURL(of reservation: Reservation, today: TodayModel) -> URL? {
        today.files(for: reservation).isEmpty ? nil : BookingLink.url(reservation.id)
    }
}
