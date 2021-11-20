//
//  UIView+layer.swift
//  Pinely
//

import UIKit

extension UIView {
    @IBInspectable var borderWidth: CGFloat {
        get { layer.borderWidth }
        set {
            layer.borderWidth = newValue
            if dropShadow {
                updateShadow()
            }
        }
    }

    @IBInspectable var borderColor: UIColor? {
        get { layer.borderColor?.UIColor }
        set {
            layer.borderColor = newValue?.cgColor
            if dropShadow {
                updateShadow()
            }
        }
    }

    @IBInspectable var cornerRadius: CGFloat {
        get { layer.cornerRadius  }
        set {
            layer.cornerRadius = newValue
            if dropShadow {
                updateShadow()
            }
        }
    }

    @IBInspectable var masksToBounds: Bool {
        get { layer.masksToBounds  }
        set { layer.masksToBounds = newValue }
    }
}
