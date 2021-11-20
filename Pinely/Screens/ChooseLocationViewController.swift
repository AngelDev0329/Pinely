//
//  ChooseLocationViewController.swift
//  Pinely
//

import UIKit
import CoreLocation

class ChooseLocationViewController: ViewController {
    let locationManager = CLLocationManager()

    var loading: BlurryLoadingView?

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblText: UILabel!
    @IBOutlet weak var lblButton1: UILabel!
    @IBOutlet weak var lblButton2: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let translation = AppDelegate.translation {

            lblTitle.text = translation.getString("location_title") ?? lblTitle.text
            lblText.text = translation.getString("location_description") ?? lblText.text
            lblButton1.text = translation.getString("location_button_text1") ?? lblButton1.text
            lblButton2.text = translation.getString("location_button_text2") ?? lblButton2.text
        }
    }

    @IBAction func useLocation() {
        UIDevice.vibrate()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.locationManager.requestWhenInUseAuthorization()

            if CLLocationManager.locationServicesEnabled() {
                self.loading = BlurryLoadingView.showAndStart()
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapCancel(_:)))
                self.loading?.addGestureRecognizer(tapGesture)

                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
                self.locationManager.startUpdatingLocation()
            }
        }
    }

    @IBAction func enterLocation() {
        UIDevice.vibrate()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.performSegue(withIdentifier: "EnterLocation", sender: self)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
    }

    @objc func tapCancel(_ notification: NSNotification) {
        loading?.stopAndHide()
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
    }
}

extension ChooseLocationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            loading?.stopAndHide()
            Town.chooseNearestTo(latitude: location.coordinate.latitude,
                                 longitude: location.coordinate.longitude)
            goBack()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        loading?.stopAndHide()
        let alert = UIAlertController(title: "alert.ops".localized,
                                      message: "alert.requireLocation".localized,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "button.cancel".localized, style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "button.settings".localized, style: .cancel) { (_) in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        })
        present(alert, animated: true, completion: nil)
    }
}
