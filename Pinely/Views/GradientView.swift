//
//  GradientView.swift
//  Pinely
//

import UIKit

@IBDesignable
class GradientView: UIView {
    enum Direction: Int {
        case horizontal
        case vertical
    }

    @IBInspectable var startColor: UIColor = .white {
        didSet {
            gradientLayer?.colors = [
                startColor.cgColor,
                endColor.cgColor
            ]
        }
    }
    @IBInspectable var endColor: UIColor = .black {
        didSet {
            gradientLayer?.colors = [
                startColor.cgColor,
                endColor.cgColor
            ]
        }
    }
    @IBInspectable var direction: Int = Direction.horizontal.rawValue {
        didSet {
            if direction == Direction.horizontal.rawValue {
                gradientLayer?.startPoint = CGPoint(x: 0.0, y: 0.5)
                gradientLayer?.endPoint = CGPoint(x: 1.0, y: 0.5)
            } else {
                gradientLayer?.startPoint = CGPoint(x: 0.5, y: 0.0)
                gradientLayer?.endPoint = CGPoint(x: 0.5, y: 1.0)
            }
        }
    }

    var gradientLayer: CAGradientLayer?

    override func layoutSubviews() {
        super.layoutSubviews()

        if gradientLayer == nil {
            gradientLayer = CAGradientLayer()
            gradientLayer!.colors = [
                startColor.cgColor,
                endColor.cgColor
            ]

            if direction == Direction.horizontal.rawValue {
                gradientLayer!.startPoint = CGPoint(x: 0.0, y: 0.5)
                gradientLayer!.endPoint = CGPoint(x: 1.0, y: 0.5)
            } else {
                gradientLayer!.startPoint = CGPoint(x: 0.5, y: 0.0)
                gradientLayer!.endPoint = CGPoint(x: 0.5, y: 1.0)
            }

            layer.addSublayer(gradientLayer!)
        }

        gradientLayer?.cornerRadius = layer.cornerRadius
        gradientLayer?.frame = self.bounds
    }
}
