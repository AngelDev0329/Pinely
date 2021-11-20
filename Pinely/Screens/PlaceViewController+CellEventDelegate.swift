//
//  PlaceViewController+CellEventDelegate.swift
//  Pinely
//

import UIKit
import FirebaseAnalytics

extension PlaceViewController: CellEventDelegate {
    func eventSelected(event: Event?) {
        UIDevice.vibrate()

        guard let event = event else {
            return
        }

        Analytics.logEvent("visit_event", parameters: [
            "id_local": event.id ?? 0,
            "name_event": event.name
        ])

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.performSegue(withIdentifier: "Event", sender: event)
        }
    }
}
