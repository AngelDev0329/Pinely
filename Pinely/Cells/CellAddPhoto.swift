//
//  CellAddPhoto.swift
//  Pinely
//

import UIKit

class CellAddPhoto: UICollectionViewCell {
    @IBOutlet weak var vShadeFrame: UIView!

    func prepare() {
        vShadeFrame.updateShadow()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
            self?.vShadeFrame.updateShadow()
        }
    }
}
