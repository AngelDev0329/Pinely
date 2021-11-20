//
//  StaffChooseLocationViewController.swift
//  Pinely
//

import UIKit
import Alamofire
import GoogleMaps

class StaffChooseLocationViewController: ViewController {
    @IBOutlet weak var tfAddress: UITextField!
    @IBOutlet weak var tfCoordinates: UITextField!
    @IBOutlet weak var tfLocation: UITextField!

    @IBOutlet weak var vMapContainer: UIView!

    @IBOutlet weak var vInfoPanel: UIView!

    var needToCreate = false
    var newType: String?
    var newName: String?
    var newSlogan: String?
    var newDescription: String?

    var nearestCityOrTown: CityOrTown?

    var mapView: GMSMapView?
    var marker: GMSMarker?

    @IBAction func appearPanel() {
        vInfoPanel.alpha = 0.0
        vInfoPanel.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.vInfoPanel.alpha = 1.0
        }
    }

    @IBAction func hidePanel() {
        UIView.animate(withDuration: 0.3) {
            self.vInfoPanel.alpha = 0.0
        } completion: { (_) in
            self.vInfoPanel.isHidden = true
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if mapView == nil {
            let camera = GMSCameraPosition.camera(withLatitude: 40.4168, longitude: -3.7038, zoom: 6.0)
            mapView = GMSMapView.map(withFrame: vMapContainer.bounds, camera: camera)
            mapView!.delegate = self
            vMapContainer.addSubview(mapView!)
        }
    }

    @IBAction func continueCreation() {
        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            guard let nearestCityOrTown = self.nearestCityOrTown else {
                self.showError("Location not selected")
                return
            }

            var idCountrie = 0
            var idCity = 0
            var idTown: Int?

            if let town = nearestCityOrTown as? Town {
                idCountrie = town.city?.idCountry ?? town.country?.id ?? 0
                idCity = town.idCity ?? 0
                idTown = town.id
            } else if let city = nearestCityOrTown as? City {
                idCountrie = city.idCountry ?? 0
                idCity = city.id
                idTown = nil
            }

            if self.needToCreate {
                let loadingView = LoadingView.showAndRun(text: "loading.creatingSala".localized,
                                                         viewController: self)
                let args = NewLocalArguments(type: self.newType ?? "", nameLocal: self.newName ?? "",
                                             subTitle: self.newSlogan ?? "", description: self.newDescription ?? "",
                                             ubication: self.tfCoordinates.text ?? "", idCountrie: idCountrie,
                                             idCitie: idCity, idTown: idTown)
                API.shared.createNewLocal(args) { (place, local, error) in
                    loadingView?.stopAndRemove()

                    if let error = error {
                        self.show(error: error)
                        return
                    }

                    self.performSegue(withIdentifier: "PlaceEdit", sender: (place, local))
                }
            } else {
                self.goBack()
            }
        }
    }

    private func showAddressFromCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { (response, _) in
            if let response = response,
               let result = response.firstResult() {
                var address: String = ""
                result.lines?.forEach {
                    if !$0.isEmpty {
                        if !address.isEmpty {
                            address += ", "
                        }
                        address += $0
                    }
                }
                self.tfAddress.text = address
            }
        }
    }

    func selectedCoordinate(_ coordinate: CLLocationCoordinate2D) {
        showAddressFromCoordinate(coordinate)

        mapView?.clear()

        marker = GMSMarker()
        marker!.icon = #imageLiteral(resourceName: "MapMarker")
        marker!.groundAnchor = CGPoint(x: 0.48611, y: 0.84615)
        marker!.position = coordinate
        marker!.map = mapView

        tfCoordinates.text = String(format: "%f, %f", coordinate.latitude, coordinate.longitude)

        nearestCityOrTown = nil
        var minDistance: Double?
        var allCitiesAndTowns: [CityOrTown] = []
        let coordinate = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        allCitiesAndTowns.append(contentsOf: City.shared)
        allCitiesAndTowns.append(contentsOf: Town.shared)
        for town in allCitiesAndTowns {
            guard let townLat = town.latitude,
                  let townLng = town.longitude
            else { continue }

            let townCoordinate = CLLocation(latitude: townLat, longitude: townLng)
            let distanceInMeters = coordinate.distance(from: townCoordinate)
            if minDistance == nil || distanceInMeters < minDistance! {
                minDistance = distanceInMeters
                nearestCityOrTown = town
            }
        }

        if let ncot = nearestCityOrTown {
            tfLocation.text = ncot.getFullName()
        } else {
            tfLocation.text = ""
        }

        let camera = GMSCameraPosition.camera(withLatitude: coordinate.coordinate.latitude, longitude: coordinate.coordinate.longitude, zoom: 16.0)
        mapView?.animate(to: camera)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let staffPlaceEditVC = segue.destination as? StaffPlaceEditViewController {
            if let placeAndLocal = sender as? (Place?, Local?) {
                staffPlaceEditVC.place = placeAndLocal.0
                staffPlaceEditVC.local = placeAndLocal.1
            }
            staffPlaceEditVC.changed = true
        }
    }

    private func processGeocoderResponse(_ response: AFDataResponse<Data>) {
        switch response.result {
        case .success(let data):
            guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
                print("Can't parse JSON")
                return
            }

            if let results = json["results"] as? [Any],
               let result0 = results.first as? [String: Any],
               let geometry = result0["geometry"] as? [String: Any],
               let location = geometry["location"] as? [String: Any],
               let latitude = location.getDouble("lat"),
               let longitude = location.getDouble("lng") {
                self.selectedCoordinate(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
            }

        case .failure(let error):
            print(error)
        }
    }
}

extension StaffChooseLocationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == tfAddress {
            let address = textField.text ?? ""
            if address.count > 3 {
                let apiKey = "AIzaSyByi54AqKtkY1PSBuJNpXw16gAuqO0PVOQ"
                let postParameters: [String: Any] = [
                    "address": address,
                    "key": apiKey
                ]
                let url: String = "https://maps.googleapis.com/maps/api/geocode/json"

                AF.request(url, method: .get, parameters: postParameters, encoding: URLEncoding.default, headers: nil)
                    .responseData(completionHandler: { [weak self] (response) in
                        self?.processGeocoderResponse(response)
                    })
            }
        }
        return false
    }
}

extension StaffChooseLocationViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        selectedCoordinate(coordinate)
    }
}
