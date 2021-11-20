//
//  UIViewController+goBack.swift
//  Pinely
//

import UIKit

extension UIViewController {
    @IBAction func goBack() {
        if let navigationController = self.navigationController,
           navigationController.viewControllers.count >= 2 {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}
