//
//  UICollectionView+register.swift
//  Pinely
//

import UIKit

extension UICollectionView {
    func register(nibName: String, reusableId: String) {
        register(UINib(nibName: nibName, bundle: nil), forCellWithReuseIdentifier: reusableId)
    }
}
