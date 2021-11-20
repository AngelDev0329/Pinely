//
//  CellAddEvent.swift
//  Pinely
//

import UIKit

protocol CellAddEventDelegate: AnyObject {
    func addEvent()
}

class CellAddEvent: UICollectionViewCell {
    @IBOutlet weak var vContainer: UIView!

    weak var delegate: CellAddEventDelegate?

    func prepare(delegate: CellAddEventDelegate?) {
        vContainer.transform = CGAffineTransform(scaleX: 1, y: 1)

        self.delegate = delegate
    }

    @IBAction func addEvent() {
        delegate?.addEvent()
    }
}
