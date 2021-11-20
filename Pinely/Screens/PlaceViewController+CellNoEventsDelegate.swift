//
//  PlaceViewController+CellNoEventsDelegate.swift
//  Pinely
//

import UIKit

extension PlaceViewController: CellNoEventsDelegate {
    func contactDirectly(place: Place) {
        if let localId = place.id {
            API.shared.addInterestLocal(localId: localId)
        }
        _ = local?.openInstagram()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.showMessagePanel()
        }
    }
}
