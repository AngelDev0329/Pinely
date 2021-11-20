//
//  UITextField+nameFromFirebase.swift
//  Pinely
//

import FirebaseAuth
import UIKit

extension UITextField {
    func setFirstNameFromFirebase() {
        guard let fireUser = Auth.auth().currentUser else {
            return
        }

        let name = fireUser.displayName?.components(separatedBy: " ") ?? []
        if name.isEmpty {
            text = ""
        } else {
            text = name[0]
        }
    }

    func setLastNameFromFirebase() {
        guard let fireUser = Auth.auth().currentUser else {
            return
        }

        let name = fireUser.displayName?.components(separatedBy: " ") ?? []
        if name.count <= 1 {
            text = ""
        } else if name.count == 2 {
            text = name[1]
        } else {
            text = name[1...].joined(separator: " ")
        }
    }
}
