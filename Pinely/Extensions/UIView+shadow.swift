//
//  UIView+shadow.swift
//  Pinely
//

import UIKit

extension UIView {
    @IBInspectable var dropShadow: Bool {
        get {
            layer.shadowOpacity > 0.0 && layer.shadowRadius > 0
        }
        set {
            if newValue {
                updateShadow()
            } else {
                layer.shadowColor = UIColor.clear.cgColor
                layer.shadowOpacity = 0.0
                layer.shadowRadius = 0

                layer.shadowPath = nil
                layer.shouldRasterize = false
            }
        }
    }

    @IBInspectable var shadowOffsetY: CGFloat {
        get {
            layer.shadowOffset.height
        }
        set {
            layer.shadowOffset.height = newValue
        }
    }

    func updateShadow() {
        updateShadow(bounds: bounds)
    }

    func updateShadow(bounds: CGRect) {
        self.updateShadow(bounds: bounds, opacity: 0.16)
    }

    func updateShadow(bounds: CGRect, opacity: Float) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = 4

        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }

    func updateAllShadows() {
        if self.dropShadow {
            updateShadow()
        }

        for subview in subviews {
            subview.updateAllShadows()
        }
    }

}
