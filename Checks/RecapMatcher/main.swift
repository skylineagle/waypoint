import Foundation

let start = Date(timeIntervalSince1970: 1_000_000)
func at(_ minutes: Double) -> Date { start.addingTimeInterval(minutes * 60) }

let station = RecapMatcher.Place(id: 1, latitude: 35.6812, longitude: 139.7671, arrival: at(0))
let hotel = RecapMatcher.Place(id: 2, latitude: 34.6687, longitude: 135.5013, arrival: at(240))
let tour = RecapMatcher.Place(id: 3, latitude: nil, longitude: nil, arrival: at(480))
let places = [station, hotel, tour]

func photo(_ id: String, _ minutes: Double, _ lat: Double? = nil, _ lng: Double? = nil, favorite: Bool = false) -> RecapMatcher.Photo {
    RecapMatcher.Photo(id: id, date: at(minutes), latitude: lat, longitude: lng, isFavorite: favorite)
}

assert(RecapMatcher.placeID(of: photo("a", 10, 35.6815, 139.7675), among: places) == 1, "near the station by GPS")
assert(RecapMatcher.placeID(of: photo("b", 10, 34.6690, 135.5010), among: places) == 2, "GPS wins over time")
assert(RecapMatcher.placeID(of: photo("c", 10, 40.0, 140.0), among: places) == 1, "GPS far from every place falls back to time")
assert(RecapMatcher.placeID(of: photo("g", 500, 40.0, 140.0), among: places) == 3, "GPS fallback reaches a place without coordinates")
assert(RecapMatcher.placeID(of: photo("d", 300), among: places) == 2, "no GPS: last place arrived at")
assert(RecapMatcher.placeID(of: photo("e", 600), among: places) == 3, "no GPS: place without coordinates still matches by time")
assert(RecapMatcher.placeID(of: photo("f", -5), among: places) == nil, "no GPS: before the first arrival")

let ten = (0..<10).map { photo("p\($0)", Double($0)) }
assert(RecapMatcher.picks(from: ten) == ["p0", "p3", "p6"], "spread across the visit")
var withFavorite = ten
withFavorite[8].isFavorite = true
assert(RecapMatcher.picks(from: withFavorite).first == "p8", "favourite first")
assert(RecapMatcher.picks(from: withFavorite).count == 3)
assert(RecapMatcher.picks(from: Array(ten.prefix(2))) == ["p0", "p1"], "fewer than three")
assert(RecapMatcher.picks(from: []).isEmpty)

let asakusa = RecapMatcher.Place(id: 10, latitude: 35.7148, longitude: 139.7967, arrival: at(0))
let kappabashi = photo("k1", 70, 35.7135, 139.7880)
let kappabashiAgain = photo("k2", 75, 35.7137, 139.7882)
let kappabashiLater = photo("k3", 200, 35.7134, 139.7879)
let ueno = photo("u1", 120, 35.7120, 139.7740)
assert(!RecapMatcher.isUnplanned(photo("n", 5, 35.7150, 139.7965), among: [asakusa]), "near a planned stop is planned")
assert(!RecapMatcher.isUnplanned(photo("x", 5), among: [asakusa]), "no GPS is never a suggestion")
assert(RecapMatcher.isUnplanned(kappabashi, among: [asakusa]), "far from every stop is unplanned")
let spots = RecapMatcher.spots(of: [ueno, kappabashiLater, kappabashi, kappabashiAgain])
assert(spots.map { $0.map(\.id) } == [["k1", "k2", "k3"], ["u1"]], "photos within 50 m share a spot, in time order")
assert(RecapMatcher.spots(of: [photo("s", 0, 35.0, 139.0)]).count == 1, "a single photo is a spot")
assert(RecapMatcher.insertionIndex(of: at(70), among: [at(0), at(60), at(180)]) == 2, "between the stops around it")
assert(RecapMatcher.insertionIndex(of: at(70), among: [at(0), nil, at(180)]) == 1, "stops without a time are not anchors")
assert(RecapMatcher.insertionIndex(of: at(-10), among: [at(0), at(60)]) == 0, "before the first stop")
assert(RecapMatcher.insertionIndex(of: at(70), among: [nil, nil]) == 2, "no times at all goes last")
print("RecapMatcher checks passed")
