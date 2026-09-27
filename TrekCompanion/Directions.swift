import UIKit

enum Directions {
    static func open(to place: StopPlace) {
        guard let latitude = place.lat, let longitude = place.lng else { return }
        UIApplication.shared.open(AppSettings.directionsApp.url(latitude: latitude, longitude: longitude))
    }
}
