//
//  DarkMode.swift
//  Pinely
//

import UIKit

class DarkMode {
    static func activate(viewController: ViewController) {
        isEnabled = viewController.isDarkMode
    }

    static var isEnabled = false
}
