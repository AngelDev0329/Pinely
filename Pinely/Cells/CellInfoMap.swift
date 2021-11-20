//
//  CellInfoMap.swift
//  Pinely
//

import UIKit
import MapKit

class InfoMapAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?

    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
    }
}

class CellInfoMap: UICollectionViewCell {
    @IBOutlet weak var map: MKMapView!

    var local: Local?
    weak var viewController: ViewController?

    func prepare(local: Local, viewController: ViewController?) {
        self.local = local
        self.viewController = viewController

        let title = local.localName ?? ""

        guard let location = local.ubication else {
            return
        }

        let viewRegion = MKCoordinateRegion(center: location, latitudinalMeters: 200, longitudinalMeters: 200)
        map.setRegion(viewRegion, animated: false)

        map.removeAnnotations(map.annotations)
        map.addAnnotation(InfoMapAnnotation(title: title, coordinate: location))
    }

    @IBAction func placeSelected() {
        guard let local = self.local,
              let location = local.ubication
        else {
            return
        }

        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.viewController?.openMapButtonAction(
                latitude: location.latitude,
                longitude: location.longitude)
        }
    }
}
