//
//  StaffPlaceEditViewController+CellAddEventDelegate.swift
//  Pinely
//

import UIKit

extension StaffPlaceEditViewController: CellAddEventDelegate {
    func addEvent() {
        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.performSegue(withIdentifier: "StaffCreateEvent", sender: self)
        }
    }
}
