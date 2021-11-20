//
//  HomeViewController+CellEventDelegate.swift
//  Pinely
//

import FirebaseAnalytics
import UIKit

extension HomeViewController: CellEventDelegate {
    func eventSelected(event: Event?) {
        guard let event = event, let idLocal = event.idLocal else {
            return
        }

        UIDevice.vibrate()

        Analytics.logEvent("visit_event", parameters: [
            "id_local": event.id ?? 0,
            "name_event": event.name
        ])
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let selectedPlace = self.places.first(where: { $0.id == idLocal })

            self.performSegue(withIdentifier: "Event",
                              sender: (event, selectedPlace, idLocal, self.locals[idLocal]))
        }
    }
}
