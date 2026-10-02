import SwiftUI

struct MapTimelineSheet: View {
    let caption: String
    let trailing: String
    let stops: [TripStop]
    let doneIDs: Set<Int>
    let nextID: Int?
    let legs: [Int: TravelLeg]
    let journeys: [Int: Reservation]
    let onSelect: (TripStop) -> Void
    let onToggle: ((TripStop) -> Void)?
    @State private var isShowingDone = false

    private var numbered: [(stop: TripStop, number: Int)] {
        stops.enumerated().map { ($0.element, $0.offset + 1) }
    }

    private var done: [(stop: TripStop, number: Int)] {
        numbered.filter { doneIDs.contains($0.stop.id) }
    }

    private var visible: [(stop: TripStop, number: Int)] {
        isShowingDone ? numbered : numbered.filter { !doneIDs.contains($0.stop.id) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                CardCaption(text: caption)
                Spacer()
                CardCaption(text: trailing)
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            ScrollViewReader { proxy in
                ScrollView {
                    timeline
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                    Color.clear.containerRelativeFrame(.vertical) { height, _ in height * 0.6 }
                }
                .onAppear { proxy.scrollTo(nextID, anchor: .top) }
                .onChange(of: nextID) { _, id in withAnimation(.smooth) { proxy.scrollTo(id, anchor: .top) } }
            }
        }
        .animation(.snappy, value: doneIDs)
        .animation(.snappy, value: isShowingDone)
    }

    private var timeline: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !done.isEmpty { doneToggle }
            ForEach(visible, id: \.stop.id) { item in
                if let journey = journeys[item.stop.id] {
                    JourneyLegLabel(reservation: journey)
                } else if let leg = legs[item.stop.id], !doneIDs.contains(item.stop.id), item.number > 1 {
                    TravelLegLabel(leg: leg, isOnGlass: true)
                }
                row(item.stop, number: item.number)
                    .id(item.stop.id)
            }
        }
        .background(alignment: .leading) {
            Rectangle()
                .fill(.primary.opacity(0.15))
                .frame(width: 1.5)
                .padding(.vertical, 14)
                .padding(.leading, 12.25)
        }
    }

    private var doneToggle: some View {
        Button {
            isShowingDone.toggle()
        } label: {
            HStack(spacing: 10) {
                TimelineDot(number: 0, state: .done, isOnGlass: true)
                Text(nextID == nil ? "All \(done.count) done" : "\(done.count) done")
                    .font(.poppins(13, .medium))
                    .foregroundStyle(.secondary)
                Image(systemName: isShowingDone ? "chevron.up" : "chevron.down")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func row(_ stop: TripStop, number: Int) -> some View {
        let state: StopRow.StopState = stop.id == nextID ? .next : doneIDs.contains(stop.id) ? .done : .upcoming
        let isNext = state == .next
        return HStack(spacing: 10) {
            TimelineDot(number: number, state: state, isOnGlass: true)
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(stop.place.name)
                        .font(.poppins(isNext ? 15 : 14, isNext ? .bold : .medium))
                        .foregroundStyle(state == .done ? .secondary : .primary)
                        .strikethrough(state == .done)
                        .lineLimit(1)
                    if isNext, let notes = stop.notes {
                        Text(notes)
                            .font(.poppins(11.5, relativeTo: .caption))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                if let time = stop.assignmentTime {
                    Text(time.prefix(5))
                        .font(.poppins(12, .medium))
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
                if state != .done {
                    Button("Directions to \(stop.place.name)", systemImage: "arrow.triangle.turn.up.right.diamond.fill") {
                        Directions.open(to: stop.place)
                    }
                    .labelStyle(.iconOnly)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 34, height: 34)
                    .background(.primary.opacity(0.14), in: .circle)
                    .buttonStyle(.plain)
                }
                if isNext, let onToggle {
                    Button("Done", systemImage: "checkmark") { onToggle(stop) }
                        .labelStyle(.iconOnly)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.trekAccentText)
                        .frame(width: 34, height: 34)
                        .background(Color.trekAccent, in: .circle)
                        .buttonStyle(.plain)
                }
            }
            .padding(.leading, isNext ? 14 : 0)
            .padding(.trailing, isNext ? 8 : 0)
            .padding(.vertical, isNext ? 10 : 2)
            .background {
                if isNext {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.primary.opacity(0.08))
                        .strokeBorder(.primary.opacity(0.12))
                }
            }
        }
        .frame(minHeight: 40)
        .contentShape(.rect)
        .onTapGesture { onSelect(stop) }
    }
}
