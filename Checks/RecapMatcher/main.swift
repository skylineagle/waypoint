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
print("RecapMatcher checks passed")
