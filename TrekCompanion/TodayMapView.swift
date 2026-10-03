import MapKit
import SwiftUI

struct TodayMapView: View {
    let stops: [TripStop]
    let doneIDs: Set<Int>
    let nextID: Int?
    var focusID: Int?
    var coveredTop: CGFloat = 0
    var coveredBottom: CGFloat = 0
    let onSelect: (TripStop) -> Void
    @State private var position = MapCameraPosition.automatic
    @State private var selectedID: Int?
    @State private var height: CGFloat = 0
    @Namespace private var mapScope

    private var coordinates: [CLLocationCoordinate2D] {
        stops.compactMap(\.place.coordinate)
    }

    var body: some View {
        Map(position: $position, selection: $selectedID, scope: mapScope) {
            UserAnnotation {
                Circle()
                    .fill(Color(.systemBlue))
                    .frame(width: 16, height: 16)
                    .overlay(Circle().strokeBorder(.white, lineWidth: 3))
                    .shadow(color: .black.opacity(0.25), radius: 2, y: 1)
                    .background(Circle().fill(Color(.systemBlue).opacity(0.18)).frame(width: 44, height: 44))
            }
            MapPolyline(coordinates: coordinates)
                .stroke(Color.trekAccent.opacity(0.7), style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [6, 6]))
            ForEach(Array(stops.enumerated()), id: \.element.id) { index, stop in
                if let coordinate = stop.place.coordinate {
                    Annotation(stop.place.name, coordinate: coordinate, anchor: .center) {
                        MapStopPin(number: index + 1, category: stop.place.category, isDone: doneIDs.contains(stop.id), isNext: stop.id == nextID)
                    }
                    .tag(stop.id)
                }
            }
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        .mapControls { MapCompass() }
        .overlay(alignment: .bottomTrailing) {
            MapUserLocationButton(scope: mapScope)
                .padding(10)
        }
        .safeAreaPadding(.bottom, coveredBottom)
        .mapScope(mapScope)
        .onGeometryChange(for: CGFloat.self, of: \.size.height) { height = $0 }
        .onChange(of: height == 0) { focusOnNext(animated: false) }
        .onAppear {
            if let focusID { focus(on: focusID, animated: false) } else { focusOnNext(animated: false) }
        }
        .onChange(of: framedStops.map(\.id)) { focusOnNext(animated: true) }
        .onChange(of: focusID) { _, id in focus(on: id, animated: true) }
        .onChange(of: coveredBottom) { refocus() }
        .onChange(of: selectedID) { _, id in
            guard let id, let stop = stops.first(where: { $0.id == id }) else { return }
            focus(on: id, animated: true)
            onSelect(stop)
            selectedID = nil
        }
    }

    private func refocus() {
        if let focusID {
            focus(on: focusID, animated: true)
        } else {
            focusOnNext(animated: true)
        }
    }

    private func focus(on id: Int?, animated: Bool) {
        guard let coordinate = stops.first(where: { $0.id == id })?.place.coordinate else {
            position = .automatic
            return
        }
        move(to: .region(visibleRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012))), animated: animated)
    }

    private var framedStops: [TripStop] {
        guard let index = stops.firstIndex(where: { $0.id == nextID }) else { return [] }
        return stops[index...].filter { !doneIDs.contains($0.id) }.prefix(2).filter { $0.place.coordinate != nil }
    }

    private func focusOnNext(animated: Bool) {
        let framed = framedStops.compactMap(\.place.coordinate)
        guard !framed.isEmpty else {
            position = .automatic
            return
        }
        let latitudes = framed.map(\.latitude)
        let longitudes = framed.map(\.longitude)
        let region = visibleRegion(
            center: CLLocationCoordinate2D(latitude: (latitudes.min()! + latitudes.max()!) / 2, longitude: (longitudes.min()! + longitudes.max()!) / 2),
            span: MKCoordinateSpan(latitudeDelta: max((latitudes.max()! - latitudes.min()!) * 1.8, 0.004), longitudeDelta: max((longitudes.max()! - longitudes.min()!) * 1.8, 0.004))
        )
        move(to: .region(region), animated: animated)
    }

    private func visibleRegion(center: CLLocationCoordinate2D, span: MKCoordinateSpan) -> MKCoordinateRegion {
        let safeHeight = height - coveredBottom
        let visibleHeight = safeHeight - coveredTop
        guard safeHeight > 0, visibleHeight > 0 else { return MKCoordinateRegion(center: center, span: span) }
        let latitudeDelta = span.latitudeDelta * safeHeight / visibleHeight
        let shift = -latitudeDelta * coveredTop / 2 / safeHeight
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: center.latitude - shift, longitude: center.longitude),
            span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: span.longitudeDelta)
        )
    }

    private func move(to camera: MapCameraPosition, animated: Bool) {
        if animated {
            withAnimation(.smooth(duration: 0.6)) { position = camera }
        } else {
            position = camera
        }
    }
}
