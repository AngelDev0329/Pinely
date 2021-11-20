import UIKit

extension UIView {

  @discardableResult func gPin(on type1: NSLayoutConstraint.Attribute,
             view: UIView? = nil, on type2: NSLayoutConstraint.Attribute? = nil,
             constant: CGFloat = 0,
             priority: Float? = nil) -> NSLayoutConstraint? {
    guard let view = view ?? superview else {
      return nil
    }

    translatesAutoresizingMaskIntoConstraints = false
    let type2 = type2 ?? type1
    let constraint = NSLayoutConstraint(item: self, attribute: type1,
                                        relatedBy: .equal,
                                        toItem: view, attribute: type2,
                                        multiplier: 1, constant: constant)
    if let priority = priority {
      constraint.priority = UILayoutPriority(priority)
    }

    constraint.isActive = true

    return constraint
  }

  func gPinEdges(view: UIView? = nil) {
    gPin(on: .top, view: view)
    gPin(on: .bottom, view: view)
    gPin(on: .left, view: view)
    gPin(on: .right, view: view)
  }

  func gPin(size: CGSize) {
    gPin(width: size.width)
    gPin(height: size.height)
  }

  func gPin(width: CGFloat) {
    translatesAutoresizingMaskIntoConstraints = false
    addConstraint(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width))
  }

  func gPin(height: CGFloat) {
    translatesAutoresizingMaskIntoConstraints = false
    addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height))
  }

  func gPin(greaterThanHeight height: CGFloat) {
    translatesAutoresizingMaskIntoConstraints = false
    addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height))
  }

  func gPinHorizontally(view: UIView? = nil, padding: CGFloat) {
    gPin(on: .left, view: view, constant: padding)
    gPin(on: .right, view: view, constant: -padding)
  }

  func gPinUpward(view: UIView? = nil) {
    gPin(on: .top, view: view)
    gPin(on: .left, view: view)
    gPin(on: .right, view: view)
  }

  func gPinDownward(view: UIView? = nil) {
    gPin(on: .bottom, view: view)
    gPin(on: .left, view: view)
    gPin(on: .right, view: view)
  }

  func gPinCenter(view: UIView? = nil) {
    gPin(on: .centerX, view: view)
    gPin(on: .centerY, view: view)
  }
}

// https://github.com/hyperoslo/Sugar/blob/master/Sources/iOS/Constraint.swift
struct Constraint {
  static func on(constraints: [NSLayoutConstraint]) {
    constraints.forEach {
      ($0.firstItem as? UIView)?.translatesAutoresizingMaskIntoConstraints = false
      $0.isActive = true
    }
  }

  static func on(_ constraints: NSLayoutConstraint ...) {
    on(constraints: constraints)
  }
}
