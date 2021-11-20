//
//  StaffCreateLocalViewController.swift
//  Pinely
//

import UIKit

class StaffCreateLocalViewController: StaffCreateEditLocalBaseViewController {
    override func lastFieldDone() {
        continueCreation()
    }

    @IBAction func continueCreation() {
        view.endEditing(true)

        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let name = self.tfName.text ?? ""
            if name.count < 3 {
                self.showError("El nombre de tu sala tiene que ser mayor a 3 carácteres")
                return
            }

            self.performSegue(withIdentifier: "StaffChooseLocation", sender: self)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let staffChooseLocationVC = segue.destination as? StaffChooseLocationViewController {
            staffChooseLocationVC.needToCreate = true
            staffChooseLocationVC.newType = tfType.text
            staffChooseLocationVC.newName = tfName.text
            staffChooseLocationVC.newSlogan = tfSlogan.text
            staffChooseLocationVC.newDescription = tvDescription.text
        }
    }
}
