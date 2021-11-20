//
//  StaffSelectPartnerTypeViewController.swift
//  Pinely
//

import UIKit

class StaffSelectPartnerTypeViewController: ViewController {
    var country: String?

    @IBAction func selectedEmpresa() {
        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.goWithType("company")
        }
    }

    @IBAction func selectedEmpresrix() {
        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.goWithType("businessman")
        }
    }

    private func goWithType(_ type: String) {
        guard let country = self.country else {
            self.showError("No country selected")
            return
        }

        let loadingView = LoadingView.showAndRun(text: "Estamos preparando tu\ndocumentación, un momento...",
                                                 viewController: self)
        API.shared.createDocumentationStaff(country: country, type: type) { (documents, error) in
            if let error = error {
                self.show(error: error)
                return
            }

            loadingView?.stopAndRemove()
            if let homeVC = self.navigationController?.viewControllers
                .first(where: { $0 is StaffHomeViewController }) as? StaffHomeViewController {
                homeVC.docs = documents
                homeVC.staffNotEnterCountry = false
                homeVC.reloadData()
            }

            self.navigationController?.viewControllers = self.navigationController?.viewControllers
                .filter { !($0 is StaffSelectCountryViewController) } ?? []
            self.goBack()
        }
    }
}
