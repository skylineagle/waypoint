import MapKit
import SwiftUI
import WidgetKit

struct TodayView: View {
    @Environment(AppModel.self) private var app
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let model: TodayModel
    let costs: CostsModel
    @State private var highlightedID: Int?
    @State private var mapFocusID: Int?
    @State private var isScrolled = false
    @State private var scrollPhase = ScrollPhase.idle
    @State private var sheetHeight: CGFloat = 160
    @State private var photoTask: Task<Void, Never>?
    @State private var undoStop: TripStop?
    @State private var lookAroundScene: MKLookAroundScene?
    @AppStorage(AppSettings.widgetPhotosKey, store: AppGroup.defaults) private var isWidgetPhotosEnabled = true

    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                pinnedHeader
                    .padding(.horizontal, 16)
                    .padding(.bottom, 4)
                    .background {
                        if model.isMapShown {
                            mapHeaderFade.padding(.bottom, -40).ignoresSafeArea(edges: .top)
                        } else {
                            Color.trekBackground
                        }
                    }
                    .zIndex(1)
                if model.isMapShown {
                    Spacer()
                } else {
                    pages
                }
            }
            .overlay(alignment: .bottom) { backButton }
            .overlay(alignment: .bottom) { undoToast }
            .background { fullscreenMap }
            .background(Color.trekBackground)
            .toolbarVisibility(.hidden, for: .navigationBar)
            .toolbarVisibility(model.isMapShown ? .hidden : .visible, for: .tabBar)
            .sheet(isPresented: mapSheetShown) { timelineSheet }
            .lookAroundViewer(isPresented: Binding { lookAroundScene != nil } set: { if !$0 { lookAroundScene = nil } }, initialScene: lookAroundScene)
            .task { await model.load() }
            .task(id: model.viewedDay?.id) {
                guard let day = model.viewedDay else { return }
                await model.loadExtras(for: day)
            }
            .task(id: app.openedStop) { await showOpenedStop() }
            .onChange(of: model.doneIDs) { publish() }
            .onChange(of: model.legs.count) { publish() }
            .onChange(of: costs.todayTotal) { publish() }
            .onChange(of: model.days == nil) { publish() }
            .onChange(of: model.trip) { publish() }
            .onChange(of: isWidgetPhotosEnabled) { publish() }
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

    private var pages: some View {
        dayScroll(nextID: model.viewedDay.flatMap(nextID)) { content }
            .onChange(of: model.viewedDay?.id) {
                withAnimation(.smooth) { isScrolled = false }
            }
    }

    private func nextID(on day: TripDay) -> Int? {
        model.isToday(day) ? model.nextStop(on: day)?.id : nil
    }

    private func dayScroll(nextID: Int?, @ViewBuilder content: @escaping () -> some View) -> some View {
        ScrollViewReader { proxy in
            List {
                Group {
                    content()
                    if nextID != nil {
                        Color.clear.containerRelativeFrame(.vertical) { height, _ in height * 0.5 }
                    }
                }
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .contentMargins(.bottom, model.selectedDayID == nil ? 24 : 80, for: .scrollContent)
            .refreshable {
                await model.load()
                await costs.load()
            }
            .onScrollGeometryChange(for: Bool?.self, of: stripVisibility) { _, scrolled in
                guard scrollPhase == .interacting || scrollPhase == .decelerating,
                      let scrolled, scrolled != isScrolled else { return }
                withAnimation(.smooth) { isScrolled = scrolled }
            }
            .onScrollPhaseChange { _, phase, context in
                scrollPhase = phase
                guard phase == .interacting,
                      let scrolled = stripVisibility(context.geometry), scrolled != isScrolled else { return }
                withAnimation(.smooth) { isScrolled = scrolled }
            }
            .onAppear { scrollToNext(nextID, proxy: proxy, animated: false) }
            .onChange(of: nextID) { _, id in scrollToNext(id, proxy: proxy, animated: true) }
            .onChange(of: highlightedID) { _, id in
                guard let id else { return }
                withAnimation(.smooth) { proxy.scrollTo(id, anchor: .center) }
            }
        }
    }

    private func scrollToNext(_ id: Int?, proxy: ScrollViewProxy, animated: Bool) {
        guard let id else { return }
        withAnimation(animated && !reduceMotion ? .smooth(duration: 0.3) : nil) { proxy.scrollTo(id, anchor: .top) }
    }

    private func stripVisibility(_ geometry: ScrollGeometry) -> Bool? {
        let offset = geometry.contentOffset.y + geometry.contentInsets.top
        let spareHeight = geometry.contentSize.height - geometry.containerSize.height
        if offset < 4 { return false }
        if offset > 48, spareHeight > 160 { return true }
        return nil
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
            BeforeTripView(model: model, firstDay: firstDay)
        } else {
            ContentUnavailableView("Trip complete", systemImage: "suitcase.rolling.fill", description: Text("Your costs stay in the Costs tab."))
        }
    }

    @ViewBuilder
    private func dayContent(_ day: TripDay) -> some View {
        let isToday = model.isToday(day)
        let stops = day.stops
        let next = isToday ? model.nextStop(on: day) : nil
        let dayBookings = model.dayBookings(on: day)
        let bookings = dayBookings.loose
        let tonight = model.stay(for: day)
        let onToggle: ((TripStop) -> Void)? = isToday ? { toggleDone($0) } : nil
        let remaining = stops.count - stops.filter { model.doneIDs.contains($0.id) }.count

        if !stops.isEmpty {
            sectionTitle(isToday ? "Today's plan" : "Plan", badge: badge(for: day), trailing: isToday ? "\(remaining) left" : "\(stops.count) stops")
            DayTimeline(entries: day.timeline, stopCount: stops.count, doneIDs: model.doneIDs, nextID: next?.id, legs: model.legs, bookings: dayBookings, highlightedID: highlightedID, onSelect: { mapFocusID = $0.id }, onShowOnMap: showOnMap, lookAroundIDs: Set(model.lookAroundScenes.keys), onLookAround: { lookAroundScene = model.lookAroundScenes[$0.id] }, onToggle: onToggle)
            if isToday, next == nil {
                Label("Day complete", systemImage: "checkmark.seal.fill")
                    .font(.poppins(15, .semibold))
                    .foregroundStyle(Color.trekSuccess)
                    .padding(.leading, 36)
            }
            if isRecapOffered(for: day, isComplete: isToday ? next == nil : (model.daysFromToday(day) ?? 0) < 0) {
                RecapCard { app.recapDayID = day.id }
                    .padding(.top, 4)
            }
        } else {
            ContentUnavailableView("No visits planned", systemImage: "calendar", description: Text("Add places to this day in TREK."))
            ForEach(day.notesItems ?? []) { NoteRow(note: $0) }
        }
        if !bookings.isEmpty {
            sectionTitle("Bookings", badge: nil, trailing: nil)
            ForEach(bookings) { BookingRow(reservation: $0) }
        }
        if let tonight {
            sectionTitle("Tonight", badge: nil, trailing: nil)
            StayCard(caption: "Hotel · night \(tonight.night) of \(tonight.nights)", stay: tonight.stay, isCheckIn: tonight.stay.startDayId == day.id)
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
                    TodayHeader(eyebrow: eyebrow(day: day), title: day.title ?? "Day \(model.number(of: day))", isCompact: isScrolled && !model.isMapShown, weather: model.weather[day.id], weatherURL: weatherURL(for: day), isMapShown: Binding { model.isMapShown } set: { model.isMapShown = $0 })
                }
                if !isScrolled || model.isMapShown {
                    DayStrip(days: days, segments: model.segments, todayID: model.todayDay?.id, selectedID: model.viewedDay?.id, daysUntilStart: daysUntilStart, onSelect: select, onOverscrollStart: returnToOverview, inset: model.isMapShown ? 6 : 16)
                        .padding(.vertical, model.isMapShown ? 2 : 0)
                        .clipShape(.rect(cornerRadius: model.isMapShown ? 24 : 0))
                        .glassEffect(model.isMapShown ? .regular : .identity, in: .rect(cornerRadius: 24))
                        .padding(.horizontal, model.isMapShown ? 0 : -16)
                        .padding(.top, 4)
                        .transition(reduceMotion ? .opacity : .move(edge: .top).combined(with: .opacity))
                }
            }
        }
    }

    @ViewBuilder
    private var fullscreenMap: some View {
        if model.isMapShown, let day = model.viewedDay {
            TodayMapView(stops: day.stops, doneIDs: model.doneIDs, nextID: nextID(on: day), focusID: mapFocusID, coveredTop: 210, coveredBottom: sheetHeight) { stop in
                highlight(stop)
            }
            .id(day.id)
            .ignoresSafeArea()
            .transition(.opacity)
        }
    }

    private var mapHeaderFade: LinearGradient {
        LinearGradient(stops: [.init(color: Color.trekBackground, location: 0), .init(color: Color.trekBackground.opacity(0.85), location: 0.55), .init(color: Color.trekBackground.opacity(0), location: 1)], startPoint: .top, endPoint: .bottom)
    }

    private var mapSheetShown: Binding<Bool> {
        Binding { model.isMapShown && model.viewedDay != nil } set: { model.isMapShown = $0 }
    }

    @ViewBuilder
    private var timelineSheet: some View {
        if let day = model.viewedDay {
            let isToday = model.isToday(day)
            let remaining = day.stops.filter { !model.doneIDs.contains($0.id) }.count
            MapTimelineSheet(
                caption: isToday ? "Today · \(day.stops.count - remaining) of \(day.stops.count) done" : "Plan",
                trailing: isToday ? "\(remaining) left" : "\(day.stops.count) stops",
                stops: day.stops,
                doneIDs: isToday ? model.doneIDs : [],
                nextID: nextID(on: day),
                legs: model.legs,
                journeys: model.dayBookings(on: day).journeys,
                onSelect: { mapFocusID = $0.id },
                onToggle: isToday ? { toggleDone($0) } : nil
            )
                .id(day.id)
                .onGeometryChange(for: CGFloat.self, of: \.size.height) { sheetHeight = $0 }
                .presentationDetents([.height(150), .medium, .large])
                .presentationBackground { Color.trekBackground.opacity(0.6) }
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled()
        }
    }

    private var daysUntilStart: Int? {
        guard case .before(let daysUntil, _) = model.phase else { return nil }
        return daysUntil
    }

    private var jumpTarget: TripDay? {
        guard model.selectedDayID == nil, case .before(_, let firstDay) = model.phase else { return nil }
        return firstDay
    }

    private var backButton: some View {
        HStack(spacing: 8) {
            if let jumpTarget {
                pill("Jump to Day 1", systemImage: "flag.checkered") {
                    model.selectedDayID = jumpTarget.id
                }
            }
            if model.selectedDayID != nil {
                pill(model.todayDay == nil ? "Back to overview" : "Back to today", systemImage: "arrow.uturn.backward") {
                    model.selectedDayID = nil
                }
            }
        }
        .padding(.bottom, 12)
    }

    private func pill(_ title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(title, systemImage: systemImage) {
            withAnimation(.smooth, action)
        }
        .font(.poppins(14, .semibold, relativeTo: .subheadline))
        .foregroundStyle(Color.trekText)
        .padding(.horizontal, 18)
        .frame(height: 44)
        .glassEffect(.regular.interactive(), in: .capsule)
        .transition(reduceMotion ? AnyTransition(.opacity) : AnyTransition(.blurReplace.combined(with: .move(edge: .bottom))))
    }

    private func showOpenedStop() async {
        guard case .stop(let dayID, let stopID) = app.openedStop else { return }
        defer { app.openedStop = nil }
        if model.days == nil { await model.load() }
        guard let day = model.days?.first(where: { $0.id == dayID }) else { return }
        withAnimation(.smooth) {
            model.selectedDayID = model.isToday(day) ? nil : day.id
            model.isMapShown = true
            mapFocusID = stopID
        }
    }

    private func isRecapOffered(for day: TripDay, isComplete: Bool) -> Bool {
        isComplete && !DayRecap.isDone(day.id) && app.recapDayID != day.id
    }

    private func returnToOverview() {
        withAnimation(.smooth) { model.selectedDayID = nil }
    }

    private func select(_ day: TripDay) {
        withAnimation(.smooth) { model.selectedDayID = model.isToday(day) ? nil : day.id }
    }

    private func toggleDone(_ stop: TripStop) {
        let isMarkingDone = !model.doneIDs.contains(stop.id)
        withAnimation(.snappy) {
            model.toggleDone(stop)
            undoStop = isMarkingDone ? stop : nil
        }
        guard isMarkingDone else { return }
        Task {
            try? await Task.sleep(for: .seconds(4))
            if undoStop == stop { withAnimation(.smooth) { undoStop = nil } }
        }
    }

    private func showOnMap(_ stop: TripStop) {
        mapFocusID = stop.id
        withAnimation(.smooth(duration: 0.35)) { model.isMapShown = true }
    }

    @ViewBuilder
    private var undoToast: some View {
        if let undoStop {
            HStack(spacing: 12) {
                Label("Marked \(undoStop.place.name) done", systemImage: "checkmark.circle.fill")
                    .lineLimit(1)
                Button("Undo") { toggleDone(undoStop) }
                    .fontWeight(.bold)
            }
            .font(.poppins(14, .semibold, relativeTo: .subheadline))
            .foregroundStyle(Color.trekText)
            .padding(.horizontal, 18)
            .frame(minHeight: 44)
            .glassEffect(.regular.interactive(), in: .capsule)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
            .transition(reduceMotion ? AnyTransition(.opacity) : AnyTransition(.move(edge: .bottom).combined(with: .opacity)))
        }
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
        if snapshot == nil { TodaySnapshot.clear() }
        photoTask?.cancel()
        let trip = model.trip
        let stops = model.todayDay?.stops ?? []
        photoTask = Task {
            guard let snapshot else { return }
            await WidgetPhotos.prepare(trip: trip, stops: stops, snapshot: snapshot)
            guard !Task.isCancelled else { return }
            WidgetCenter.shared.reloadTimelines(ofKind: "NextStopWidget")
        }
        StopTracker.shared.sync(isActive: scenePhase == .active)
        Task {
            await TripLiveActivity.sync(with: snapshot)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    private func sectionTitle(_ title: String, badge: DayStatusBadge?, trailing: String?) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 8) {
                CardCaption(text: title)
                badge
                Spacer()
                if let trailing { CardCaption(text: trailing) }
            }
            VStack(alignment: .leading, spacing: 4) {
                CardCaption(text: title)
                badge
                if let trailing { CardCaption(text: trailing) }
            }
        }
        .padding(.top, 8)
    }

    private func eyebrow(day: TripDay) -> String {
        let number = model.number(of: day)
        let total = model.days?.count ?? number
        let segment = model.segments.first { $0.covers(dayNumber: number) }?.name
        let date = ExpenseDate.date(from: day.date)?.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated))
        return ["Day \(number) of \(total)", date, segment].compactMap(\.self).joined(separator: " · ")
    }
}
