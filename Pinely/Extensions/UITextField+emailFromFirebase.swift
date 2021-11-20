//
//  UITextField+emailFromFirebase.swift
//  Pinely
//

import FirebaseAuth
import UIKit

extension UITextField {
    func setEmailFromFirebase() {
        guard let fireUser = Auth.auth().currentUser else {
            return
        }

        let email = fireUser.email
        text = email ?? ""
    }
}
