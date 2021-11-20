//
//  CellAddPlace.swift
//  Pinely
//

import UIKit

protocol CellAddPlaceDelegate: AnyObject {
    func addPlace()
}

class CellAddPlace: UICollectionViewCell {
    @IBOutlet weak var vContainer: UIView!

    weak var delegate: CellAddPlaceDelegate?

    func prepare(delegate: CellAddPlaceDelegate?) {
        vContainer.transform = CGAffineTransform(scaleX: 1, y: 1)

        self.delegate = delegate
    }

    @IBAction func addPlace() {
        delegate?.addPlace()
    }
}
