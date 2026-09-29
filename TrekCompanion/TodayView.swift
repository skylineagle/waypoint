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
    @State private var isScrolled = false

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
                    .padding(.bottom, model.selectedDayID == nil ? 24 : 80)
                }
                .onScrollGeometryChange(for: Bool.self) { geometry in
                    geometry.contentOffset.y + geometry.contentInsets.top > 12
                } action: { _, scrolled in
                    withAnimation(.smooth) { isScrolled = scrolled }
                }
                .onChange(of: highlightedID) { _, id in
                    guard let id else { return }
                    withAnimation(.smooth) { proxy.scrollTo(id, anchor: .center) }
                }
            }
            }
            .overlay(alignment: .bottom) { backButton }
            .background(Color.trekBackground)
            .toolbarVisibility(.hidden, for: .navigationBar)
            .task { await model.load() }
            .task(id: model.viewedDay?.id) {
                guard let day = model.viewedDay else { return }
                await model.loadExtras(for: day)
            }
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
        } else if let day = model.viewedDay {
            dayContent(day)
        } else if case .before(let daysUntil, let firstDay) = model.phase {
            BeforeTripView(model: model, daysUntil: daysUntil, firstDay: firstDay)
        } else {
            ContentUnavailableView("Trip complete", systemImage: "suitcase.rolling.fill", description: Text("Your costs stay in the Costs tab."))
        }
    }

    @ViewBuilder
    private func dayContent(_ day: TripDay) -> some View {
        let isToday = model.isToday(day)
        let stops = day.stops
        let next = isToday ? model.nextStop(on: day) : nil
        let bookings = model.bookings(on: day)
        let tonight = model.stay(for: day)
        let onToggle: ((TripStop) -> Void)? = isToday ? { toggleDone($0) } : nil
        let remaining = stops.count - stops.filter { model.doneIDs.contains($0.id) }.count

        if !stops.isEmpty {
            sectionTitle(isToday ? "Today's plan" : "Plan", badge: badge(for: day), trailing: isToday ? "\(remaining) left" : "\(stops.count) stops")
            DayTimeline(entries: day.timeline, stopCount: stops.count, doneIDs: model.doneIDs, nextID: next?.id, legs: model.legs, highlightedID: highlightedID, onSelect: { mapFocusID = $0.id }, onToggle: onToggle)
            if isToday, next == nil {
                Label("Day complete", systemImage: "checkmark.seal.fill")
                    .font(.poppins(15, .semibold))
                    .foregroundStyle(Color.trekSuccess)
                    .padding(.leading, 36)
            }
        } else if bookings.isEmpty, tonight?.night == nil {
            ContentUnavailableView("Nothing planned", systemImage: "calendar", description: Text("Add places to this day in TREK."))
        }
        if !bookings.isEmpty {
            sectionTitle("Bookings", badge: nil, trailing: nil)
            ForEach(bookings) { BookingRow(reservation: $0) }
        }
        if let tonight {
            sectionTitle("Tonight", badge: nil, trailing: nil)
            StayCard(caption: "Hotel · night \(tonight.night) of \(tonight.nights)", stay: tonight.stay)
        }
        if isToday {
            TodaySpendCard(costs: costs) { app.isAddingExpense = true }
                .padding(.top, 4)
        }
    }

    @ViewBuilder
    private var pinnedHeader: some View {
        if model.errorMessage == nil, let days = model.days, !days.isEmpty {
            VStack(spacing: 10) {
                if let day = model.viewedDay {
                    TodayHeader(eyebrow: eyebrow(day: day), title: day.title ?? "Day \(model.number(of: day))", weather: model.weather[day.id], weatherURL: weatherURL(for: day), isMapShown: $isMapShown)
                }
                if !isScrolled {
                    DayStrip(days: days, todayID: model.todayDay?.id, selectedID: model.viewedDay?.id, onSelect: select)
                        .padding(.horizontal, -16)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                if isMapShown, let day = model.viewedDay, !day.stops.isEmpty {
                    TodayMapView(stops: day.stops, doneIDs: model.doneIDs, nextID: model.isToday(day) ? model.nextStop(on: day)?.id : nil, focusID: mapFocusID) { stop in
                        highlight(stop)
                    }
                    .id(day.id)
                    .frame(height: 260)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
    }

    @ViewBuilder
    private var backButton: some View {
        if model.selectedDayID != nil {
            Button(model.todayDay == nil ? "Back to overview" : "Back to today", systemImage: "arrow.uturn.backward") {
                withAnimation(.smooth) { model.selectedDayID = nil }
            }
            .font(.poppins(14, .semibold, relativeTo: .subheadline))
            .foregroundStyle(Color.trekText)
            .padding(.horizontal, 18)
            .frame(height: 44)
            .glassEffect(.regular.interactive(), in: .capsule)
            .padding(.bottom, 12)
            .transition(.blurReplace.combined(with: .move(edge: .bottom)))
        }
    }

    private func select(_ day: TripDay) {
        withAnimation(.smooth) { model.selectedDayID = model.isToday(day) ? nil : day.id }
    }

    private func toggleDone(_ stop: TripStop) {
        withAnimation(.snappy) { model.toggleDone(stop) }
    }

    private func badge(for day: TripDay) -> DayStatusBadge? {
        if model.isToday(day) { return DayStatusBadge(text: "Live", isLive: true) }
        guard let offset = model.daysFromToday(day) else { return nil }
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return DayStatusBadge(text: formatter.localizedString(from: DateComponents(day: offset)), isLive: false)
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

    private func sectionTitle(_ title: String, badge: DayStatusBadge?, trailing: String?) -> some View {
        HStack(spacing: 8) {
            CardCaption(text: title)
            badge
            Spacer()
            if let trailing { CardCaption(text: trailing) }
        }
        .padding(.top, 8)
    }

    private func eyebrow(day: TripDay) -> String {
        let number = model.number(of: day)
        let total = model.days?.count ?? number
        guard let date = ExpenseDate.date(from: day.date) else { return "Day \(number) of \(total)" }
        return "Day \(number) of \(total) · \(date.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated)))"
    }
}
