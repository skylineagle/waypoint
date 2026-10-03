import CoreLocation

let places = [
    StopVisits.Place(id: 1, latitude: 35.7100, longitude: 139.78),
    StopVisits.Place(id: 2, latitude: 35.7200, longitude: 139.78),
]

func at(_ latitude: Double, minute: Double) -> CLLocation {
    CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: 139.78), altitude: 0, horizontalAccuracy: 10, verticalAccuracy: 10, timestamp: Date(timeIntervalSince1970: minute * 60))
}

func visit(_ id: Int, from start: Double, to end: Double) -> StopVisit {
    StopVisit(stopID: id, since: Date(timeIntervalSince1970: start * 60), lastSeen: Date(timeIntervalSince1970: end * 60))
}

func check(_ condition: Bool, _ label: String) {
    precondition(condition, label)
    print("ok  \(label)")
}

var step = StopVisits.step(nil, places: places, at: at(35.7100, minute: 0), dwell: 600)
check(step.visit?.stopID == 1 && step.done == nil, "arriving starts a visit")

step = StopVisits.step(step.visit, places: places, at: at(35.7150, minute: 5), dwell: 600)
check(step.visit == nil && step.done == nil, "leaving early marks nothing")

step = StopVisits.step(visit(1, from: 0, to: 4), places: places, at: at(35.7101, minute: 11), dwell: 600)
check(step.visit?.stopID == 1 && step.done == nil, "staying past the dwell keeps you at the stop until you leave")

step = StopVisits.step(visit(1, from: 0, to: 4), places: places, at: at(35.7150, minute: 30), dwell: 600)
check(step.visit == nil && step.done == nil, "a late fix elsewhere does not count as staying")

step = StopVisits.step(visit(1, from: 0, to: 10), places: places, at: at(35.7200, minute: 15), dwell: 600)
check(step.visit?.stopID == 2 && step.done == 1, "walking to the next stop finishes a long stay")

let firstDone = [StopVisits.Place(id: 1, latitude: 35.7100, longitude: 139.78, isDone: true), places[1]]
step = StopVisits.step(visit(1, from: 0, to: 20), places: firstDone, at: at(35.7100, minute: 25), dwell: 600)
check(step.visit == nil && step.done == nil, "a stop marked done by hand is dropped")

let neighbors = [StopVisits.Place(id: 1, latitude: 35.7100, longitude: 139.78, isDone: true), StopVisits.Place(id: 3, latitude: 35.7108, longitude: 139.78)]
step = StopVisits.step(nil, places: neighbors, at: at(35.7100, minute: 30), dwell: 600)
check(step.visit == nil, "lingering at a done stop does not start its 90 m neighbor")
check(StopVisits.nearest(to: at(35.7106, minute: 0), in: neighbors) == 3, "walking over to the neighbor does")

check(StopVisits.nearest(to: at(35.7108, minute: 0), in: places) == 1, "a visit 90 m away matches the stop")
check(StopVisits.nearest(to: at(35.7150, minute: 0), in: places) == nil, "a visit between stops matches nothing")
print("all stop visit checks passed")
