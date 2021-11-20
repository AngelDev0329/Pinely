//
//  LoveViewController.swift
//  Pinely
//

import UIKit
import SwiftEventBus

class LoveViewController: ViewController {
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var vLocationShadow: UIView!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        showTown()

        SwiftEventBus.onMainThread(self, name: "townUpdated") { _ in
            self.showTown()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        SwiftEventBus.unregister(self)
    }

    private func showTown() {
        if let cityOrTown = CityOrTown.current {
            var name = cityOrTown.name
            if let town = cityOrTown as? Town {
                if let city = town.city {
                    name += ", \(city.name)"
                    if let country = city.country {
                        name += ", \(country.name)"
                    }
                }
            } else if let city = cityOrTown as? City,
                      let country = city.country {
                name += ", \(country.name)"
            }
            lblLocation.text = "en \(name)"
        } else {
            // No town selected
            lblLocation.text = "..."
        }

        self.vLocationShadow.updateShadow()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.vLocationShadow.updateShadow()
        }
    }

    @IBAction func create() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {

        }
    }

    @IBAction func chooseLocation() {
        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.performSegue(withIdentifier: "ChooseLocation", sender: self)
        }
    }
}
