import CoreLocation

struct RecapCandidate: Identifiable, Hashable {
    let name: String
    let detail: String
    let latitude: Double
    let longitude: Double

    var id: String { "\(name)|\(latitude)|\(longitude)" }
}
