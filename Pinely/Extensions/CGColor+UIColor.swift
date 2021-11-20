//
//  CGColor+UIColor.swift
//  Pinely
//

import UIKit

extension CGColor {
    var UIColor: UIKit.UIColor {
        return UIKit.UIColor(cgColor: self)
    }
}
