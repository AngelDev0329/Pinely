//
//  UINavigationController+MCMHeaderAnimatedDelegate.swift
//  Pinely
//

import UIKit

extension UINavigationController: MCMHeaderAnimatedDelegate {
    public func headerView() -> UIView {
        (viewControllers.last as? MCMHeaderAnimatedDelegate)?.headerView() ?? UIView()
    }

    public func headerCopy(subview: UIView) -> UIView {
        (viewControllers.last as? MCMHeaderAnimatedDelegate)?.headerCopy(subview: subview) ?? UIView()
    }
}
