//
//  AppFont.swift
//  Pinely
//

import Foundation
import UIKit

enum AppFont: String, CaseIterable {
    case light = "Montserrat-Light"
    case regular = "Montserrat-Regular"
    case medium = "Montserrat-Medium"
    case semiBold = "Montserrat-SemiBold"
    case bold = "Montserrat-Bold"
    case extraBold = "Montserrat-ExtraBold"

    subscript(index: CGFloat) -> UIFont {
        UIFont(name: rawValue, size: index)!
    }
}
