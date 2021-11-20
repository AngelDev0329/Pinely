//
//  UIButton+setTitleFromTranslation.swift
//  Pinely
//

import UIKit

// swiftlint:disable identifier_name
extension UIButton {
    func setTitleFromTranslation(_ key: String) {
        if let translation = AppDelegate.translation {
            setTitleFromTranslation(key, translation)
        }
    }

    func setTitleFromTranslation(_ key: String, _ translation: [String: Any]) {
        if let value = translation.getString(key) {
            setTitle(value, for: .normal)
        }
    }
}
