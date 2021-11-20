//
//  StaffPlaceEditViewController+CellEventDelegate.swift
//  Pinely
//

import UIKit

extension StaffPlaceEditViewController: CellEventDelegate {
    func eventSelected(event: Event?) {
        UIDevice.vibrate()

        if let event = event {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.performSegue(withIdentifier: "StaffEventEdit", sender: event)
            }
        }
    }
}
