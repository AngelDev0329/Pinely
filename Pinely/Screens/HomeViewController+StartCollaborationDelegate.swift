//
//  HomeViewController+StartCollaborationDelegate.swift
//  Pinely
//

import SwiftEventBus
import UIKit

extension HomeViewController: StartCollaborationDelegate {
    func startCollaboration() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let loadingView = LoadingView.showAndRun(text: "Estamos creando tu\ncuenta, un momento...", viewController: self)
            API.shared.changeRangeToStaff { (error) in
                SwiftEventBus.post("authChanged")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    loadingView?.stopAndRemove()
                    if let error = error {
                        if error.localizedDescription == "user_not_client" {
                            self.showError("error.usernotclient".localized)
                        } else {
                            self.show(error: error)
                        }
                    } else {
                        let staffStoryboard = UIStoryboard(name: "Staff", bundle: nil)
                        if let initialVC = staffStoryboard.instantiateInitialViewController() {
                            initialVC.modalPresentationStyle = .overCurrentContext
                            self.present(initialVC, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
}
