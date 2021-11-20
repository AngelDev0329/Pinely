//
//  UITextField+textPrepared.swift
//  Pinely
//

import UIKit

extension UITextField {
    var textPrepared: String {
        text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
}
