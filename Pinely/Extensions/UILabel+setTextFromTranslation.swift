//
//  UILabel+setTextFromTranslation.swift
//  Pinely
//

import UIKit

// swiftlint:disable identifier_name
extension UILabel {
    func setTextFromTranslation(_ key: String) {
        if let translation = AppDelegate.translation {
            setTextFromTranslation(key, translation)
        }
    }

    func setTextFromTranslation(_ key: String, _ translation: [String: Any]) {
       if let value = translation.getString(key) {
           text = value
       }
    }
}
