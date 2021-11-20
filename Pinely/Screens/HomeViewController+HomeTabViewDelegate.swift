//
//  HomeViewController+HomeTabViewDelegate.swift
//  Pinely
//

import FirebaseAuth
import UIKit

extension HomeViewController: HomeTabViewDelegate {
    func layoutTabs() {
        cvTabs.layoutIfNeeded()
    }

    func refreshData(delegate: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.loadData {
                delegate()
            }
        }
    }

    func contribute() {
        if Auth.auth().currentUser == nil {
            let authSb = UIStoryboard(name: "Auth", bundle: nil)
            let authVc = authSb.instantiateInitialViewController()!
            self.present(authVc, animated: true, completion: nil)
        } else {
            self.performSegue(withIdentifier: "Contribute", sender: self)
        }
    }

}
