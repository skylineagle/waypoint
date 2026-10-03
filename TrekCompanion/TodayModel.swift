import CoreLocation
import Foundation
import MapKit
import Observation

struct TravelLeg {
    let minutes: Int
    let meters: Double
    let isTransit: Bool
}

enum TripPhase {
    case before(daysUntil: Int, firstDay: TripDay?)
    case during(day: TripDay, number: Int)
    case after
}

@Observable
final class TodayModel {
    private(set) var trip: Trip
    private(set) var days: [TripDay]?
    private(set) var reservations: [Reservation] = []
    private(set) var files: [TripFile] = []
    private(set) var stays: [Stay] = []
    private(set) var segments: [TripSegment] = []
    private(set) var weather: [Int: DayWeather] = [:]
    private(set) var legs: [Int: TravelLeg] = [:]
    private(set) var stationLegs: [Int: TravelLeg] = [:]
    private(set) var errorMessage: String?
    private(set) var doneIDs: Set<Int>
    var selectedDayID: Int?
    var isMapShown = false
    private var loadedDayIDs: Set<Int> = []

    private var doneKey: String { TodaySnapshot.doneKey(tripID: trip.id) }

    init(trip: Trip) {
        self.trip = trip
        doneIDs = Set(AppGroup.defaults.array(forKey: TodaySnapshot.doneKey(tripID: trip.id)) as? [Int] ?? [])
    }

    func reloadDone() {
        doneIDs = Set(AppGroup.defaults.array(forKey: doneKey) as? [Int] ?? [])
    }

    var phase: TripPhase {
        let days = days ?? []
        let today = ExpenseDate.today
        if let index = days.firstIndex(where: { $0.date == today }) {
            return .during(day: days[index], number: index + 1)
        }
        if let start = trip.startDate, today < start, let startDate = ExpenseDate.date(from: start) {
            let calendar = Calendar.current
            let until = calendar.dateComponents([.day], from: calendar.startOfDay(for: ExpenseDate.now), to: startDate).day ?? 0
            return .before(daysUntil: until, firstDay: days.first)
        }
        return .after
    }

    var todayDay: TripDay? {
        guard case .during(let day, _) = phase else { return nil }
        return day
    }

    var viewedDay: TripDay? {
        days?.first { $0.id == selectedDayID } ?? todayDay
    }

    func isToday(_ day: TripDay) -> Bool {
        day.id == todayDay?.id
    }

    func number(of day: TripDay) -> Int {
        (days?.firstIndex { $0.id == day.id } ?? 0) + 1
    }

    func daysFromToday(_ day: TripDay) -> Int? {
        guard let date = ExpenseDate.date(from: day.date) else { return nil }
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: calendar.startOfDay(for: ExpenseDate.now), to: date).day
    }

    func nextStop(on day: TripDay) -> TripStop? {
        day.stops.first { !doneIDs.contains($0.id) }
    }

    func bookings(on day: TripDay) -> [Reservation] {
        reservations
            .filter { $0.dayId == day.id || ($0.dayId == nil && $0.date == day.date) }
            .filter { $0.type != "hotel" }
            .sorted { ($0.time ?? "") < ($1.time ?? "") }
    }

    func files(for reservation: Reservation) -> [TripFile] {
        files.filter { $0.belongs(to: reservation) }
    }

    func localFiles(for reservation: Reservation) async -> [URL] {
        guard let client = TrekClient.current else { return [] }
        var urls: [URL] = []
        for file in files(for: reservation) {
            if let url = try? await client.localCopy(of: file) { urls.append(url) }
        }
        return urls
    }

    func dayBookings(on day: TripDay) -> DayBookings {
        DayBookings(stops: day.stops, bookings: bookings(on: day))
    }

    func stay(for day: TripDay) -> (stay: Stay, night: Int, nights: Int)? {
        let order = (days ?? []).map(\.id)
        guard let dayIndex = order.firstIndex(of: day.id) else { return nil }
        for stay in stays {
            guard let startID = stay.startDayId, let endID = stay.endDayId,
                  let start = order.firstIndex(of: startID), let end = order.firstIndex(of: endID),
                  dayIndex >= start, dayIndex < end
            else { continue }
            return (stay, dayIndex - start + 1, end - start)
        }
        return nil
    }

    func previousNightStay(before day: TripDay) -> Stay? {
        let order = (days ?? []).map(\.id)
        guard let index = order.firstIndex(of: day.id), index > 0 else { return nil }
        return stay(for: (days ?? [])[index - 1])?.stay
    }

    func toggleDone(_ stop: TripStop) {
        if doneIDs.contains(stop.id) {
            doneIDs.remove(stop.id)
        } else {
            doneIDs.insert(stop.id)
        }
        AppGroup.defaults.set(Array(doneIDs), forKey: doneKey)
    }

    func load() async {
        guard let client = TrekClient.current else { return }
        do {
            async let loadedTrip = client.trip(id: trip.id)
            async let loadedDays = client.days(tripID: trip.id)
            async let loadedReservations = client.reservations(tripID: trip.id)
            async let loadedFiles = client.files(tripID: trip.id)
            async let loadedStays = client.stays(tripID: trip.id)
            async let loadedSegments = client.segments(tripID: trip.id)
            days = try await loadedDays
            segments = (try? await loadedSegments) ?? []
            trip = (try? await loadedTrip) ?? trip
            reservations = (try? await loadedReservations) ?? []
            files = (try? await loadedFiles) ?? []
            stays = (try? await loadedStays) ?? []
            errorMessage = nil
            await ReminderScheduler.update([
                .bookings: TripReminderEvents.bookings(reservations),
                .stays: TripReminderEvents.stays(stays, days: days ?? []),
                .brief: TripReminderEvents.briefs(days ?? []),
            ])
        } catch {
            errorMessage = error.localizedDescription
            return
        }
        loadedDayIDs = []
        for day in [todayDay, viewedDay].compactMap(\.self) {
            await loadExtras(for: day)
        }
    }

    func loadExtras(for day: TripDay) async {
        guard loadedDayIDs.insert(day.id).inserted else { return }
        var origin = previousNightStay(before: day)?.coordinate
        var computed: [Int: TravelLeg] = [:]
        let journeys = dayBookings(on: day).journeys
        for stop in day.stops {
            if let journey = journeys[stop.id], let origin, let station = journey.departure?.coordinate {
                stationLegs[journey.id] = await Self.leg(from: origin, to: station)
            }
            guard let destination = stop.place.coordinate else { continue }
            if let origin, let leg = await Self.leg(from: origin, to: destination) {
                computed[stop.id] = leg
            }
            origin = destination
        }
        legs.merge(computed) { $1 }
        if let anchor = day.stops.compactMap(\.place.coordinate).first ?? stay(for: day)?.stay.coordinate, let date = day.date {
            weather[day.id] = try? await TrekClient.current?.weather(latitude: anchor.latitude, longitude: anchor.longitude, date: date)
        }
    }

    private static let longestWalkMinutes = 25

    private static func leg(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) async -> TravelLeg? {
        let walk = await eta(from: origin, to: destination, by: .walking)
        if let walk, walk.minutes <= longestWalkMinutes { return walk }
        return await eta(from: origin, to: destination, by: .transit) ?? walk
    }

    private static func eta(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, by transport: MKDirectionsTransportType) async -> TravelLeg? {
        let request = MKDirections.Request()
        request.source = MKMapItem(location: CLLocation(latitude: origin.latitude, longitude: origin.longitude), address: nil)
        request.destination = MKMapItem(location: CLLocation(latitude: destination.latitude, longitude: destination.longitude), address: nil)
        request.transportType = transport
        guard let eta = try? await MKDirections(request: request).calculateETA() else { return nil }
        return TravelLeg(minutes: max(Int((eta.expectedTravelTime / 60).rounded()), 1), meters: eta.distance, isTransit: transport == .transit)
    }
}
