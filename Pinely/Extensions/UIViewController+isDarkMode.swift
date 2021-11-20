//
//  UIViewController+isDarkMode.swift
//  Pinely
//

import UIKit

extension UIViewController {
    var isDarkMode: Bool {
        return self.traitCollection.userInterfaceStyle == .dark
    }
}
