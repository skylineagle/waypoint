import SwiftUI
import WidgetKit

struct TodayView: View {
    @Environment(AppModel.self) private var app
    @Environment(\.scenePhase) private var scenePhase
    let model: TodayModel
    let costs: CostsModel
    @AppStorage("today-map-shown") private var isMapShown = false
    @State private var highlightedID: Int?
    @State private var mapFocusID: Int?

    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                pinnedHeader
                    .padding(.horizontal, 16)
                    .padding(.bottom, 4)
                    .background(Color.trekBackground)
                    .zIndex(1)
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        content
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
                .onChange(of: highlightedID) { _, id in
                    guard let id else { return }
                    withAnimation(.smooth) { proxy.scrollTo(id, anchor: .center) }
                }
            }
            }
            .background(Color.trekBackground)
            .toolbarVisibility(.hidden, for: .navigationBar)
            .task { await model.load() }
            .refreshable {
                await model.load()
                await costs.load()
            }
            .onChange(of: model.doneIDs) { publish() }
            .onChange(of: model.legs.count) { publish() }
            .onChange(of: costs.todayTotal) { publish() }
            .onChange(of: model.days == nil) { publish() }
            .onChange(of: scenePhase) { _, phase in
                StopTracker.shared.sync(isActive: phase == .active)
                guard phase == .active else { return }
                model.reloadDone()
                publish()
            }
            .onReceive(NotificationCenter.default.publisher(for: StopTracker.doneChanged)) { _ in
                model.reloadDone()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if let errorMessage = model.errorMessage {
            ContentUnavailableView("Couldn't load the plan", systemImage: "wifi.exclamationmark", description: Text(errorMessage))
        } else if model.days == nil {
            ProgressView().frame(maxWidth: .infinity, minHeight: 300)
        } else {
            switch model.phase {
            case .before(let daysUntil, let firstDay):
                BeforeTripView(model: model, daysUntil: daysUntil, firstDay: firstDay)
            case .during(let day, let number):
                during(day: day, number: number)
            case .after:
                ContentUnavailableView("Trip complete", systemImage: "suitcase.rolling.fill", description: Text("Your costs stay in the Costs tab."))
            }
        }
    }

    @ViewBuilder
    private func during(day: TripDay, number: Int) -> some View {
        let stops = day.stops
        let next = model.nextStop(on: day)

        if !stops.isEmpty {
            sectionTitle("Today's plan", trailing: "\(stops.count - stops.filter { model.doneIDs.contains($0.id) }.count) left")
            DayTimeline(entries: day.timeline, stopCount: stops.count, doneIDs: model.doneIDs, nextID: next?.id, legs: model.legs, highlightedID: highlightedID, onSelect: { mapFocusID = $0.id }) { stop in
                withAnimation(.snappy) { model.toggleDone(stop) }
            }
            if next == nil {
                Label("Day complete", systemImage: "checkmark.seal.fill")
                    .font(.poppins(15, .semibold))
                    .foregroundStyle(Color.trekSuccess)
                    .padding(.leading, 36)
            }
        }
        let bookings = model.bookings(on: day)
        if !bookings.isEmpty {
            sectionTitle("Bookings", trailing: nil)
            ForEach(bookings) { BookingRow(reservation: $0) }
        }
        if let tonight = model.stay(for: day) {
            sectionTitle("Tonight", trailing: nil)
            StayCard(caption: "Hotel · night \(tonight.night) of \(tonight.nights)", stay: tonight.stay)
        }
        TodaySpendCard(costs: costs) { app.isAddingExpense = true }
            .padding(.top, 4)
    }

    @ViewBuilder
    private var pinnedHeader: some View {
        if model.errorMessage == nil, model.days != nil, case .during(let day, let number) = model.phase {
            VStack(spacing: 10) {
                TodayHeader(eyebrow: eyebrow(day: day, number: number), title: day.title ?? "Day \(number)", weather: model.weather, weatherURL: weatherURL(for: day), isMapShown: $isMapShown)
                if isMapShown {
                    TodayMapView(stops: day.stops, doneIDs: model.doneIDs, nextID: model.nextStop(on: day)?.id, focusID: mapFocusID) { stop in
                        highlight(stop)
                    }
                    .frame(height: 260)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
    }

    private func weatherURL(for day: TripDay) -> URL? {
        let place = (model.nextStop(on: day) ?? day.stops.first)?.place
        guard let latitude = place?.lat, let longitude = place?.lng else { return URL(string: "weather://") }
        return URL(string: "weather://?lat=\(latitude)&lon=\(longitude)")
    }

    private func highlight(_ stop: TripStop) {
        highlightedID = stop.id
        Task {
            try? await Task.sleep(for: .seconds(1.6))
            if highlightedID == stop.id { highlightedID = nil }
        }
    }

    private func publish() {
        guard model.days != nil else { return }
        let snapshot = TodaySnapshotBuilder.make(today: model, costs: costs)
        snapshot?.save()
        StopTracker.shared.sync(isActive: scenePhase == .active)
        Task {
            await TripLiveActivity.sync(with: snapshot)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    private func sectionTitle(_ title: String, trailing: String?) -> some View {
        HStack {
            CardCaption(text: title)
            Spacer()
            if let trailing { CardCaption(text: trailing) }
        }
        .padding(.top, 8)
    }

    private func eyebrow(day: TripDay, number: Int) -> String {
        let total = model.days?.count ?? number
        guard let date = ExpenseDate.date(from: day.date) else { return "Day \(number) of \(total)" }
        return "Day \(number) of \(total) · \(date.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated)))"
    }
}
