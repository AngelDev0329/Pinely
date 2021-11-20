//
//  UIViewController+openMapButtonAction.swift
//  Pinely
//

import UIKit

extension UIViewController {
    func openMapButtonAction(latitude: Double, longitude: Double) {
        let appleURL = "http://maps.apple.com/?daddr=\(latitude),\(longitude)"
        let googleURL = "comgooglemaps://?daddr=\(latitude),\(longitude)&directionsmode=driving"
        let wazeURL = "waze://?ll=\(latitude),\(longitude)&navigate=false"

        let googleItem = ("Google Map", URL(string: googleURL)!)
        let wazeItem = ("Waze", URL(string: wazeURL)!)
        var installedNavigationApps = [("Apple Maps", URL(string: appleURL)!)]

        if UIApplication.shared.canOpenURL(googleItem.1) {
            installedNavigationApps.append(googleItem)
        }

        if UIApplication.shared.canOpenURL(wazeItem.1) {
            installedNavigationApps.append(wazeItem)
        }

        let alert = UIAlertController(title: "Seleccione la app de navegación",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        for navigationApp in installedNavigationApps {
            let button = UIAlertAction(title: navigationApp.0, style: .default, handler: { _ in
                UIApplication.shared.open(navigationApp.1, options: [:], completionHandler: nil)
            })
            alert.addAction(button)
        }
        let cancel = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
        }
        alert.addAction(cancel)
        present(alert, animated: true)
    }
}
