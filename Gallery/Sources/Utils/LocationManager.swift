import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
  private var clLocationManager = CLLocationManager()
  var latestLocation: CLLocation?

  override init() {
    super.init()
    clLocationManager.delegate = self
    clLocationManager.desiredAccuracy = kCLLocationAccuracyBest
    clLocationManager.requestWhenInUseAuthorization()
  }

  func start() {
    clLocationManager.startUpdatingLocation()
  }

  func stop() {
    clLocationManager.stopUpdatingLocation()
  }

  // MARK: - CLLocationManagerDelegate

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    // Pick the location with best (= smallest value) horizontal accuracy
    latestLocation = locations.sorted { $0.horizontalAccuracy < $1.horizontalAccuracy }.first
  }

  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status == .authorizedAlways || status == .authorizedWhenInUse {
      clLocationManager.startUpdatingLocation()
    } else {
      clLocationManager.stopUpdatingLocation()
    }
  }
}
