//
//  HomeViewController+CellPlaceDelegate.swift
//  Pinely
//

import FirebaseAnalytics
import UIKit

extension HomeViewController: CellPlaceDelegate {
    func placeSelected(place: Place) {
        UIDevice.vibrate()

        Analytics.logEvent("visit_local", parameters: [
            "id_local": place.id ?? 0,
            "name_event": place.name
        ])

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.performSegue(withIdentifier: "Place", sender: place)
        }
    }
}
