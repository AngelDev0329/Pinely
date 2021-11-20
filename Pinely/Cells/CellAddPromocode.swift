//
//  CellAddPromocode.swift
//  Pinely
//

import UIKit

protocol CellAddPromocodeDelegate: AnyObject {
    func addPromocode()
}

class CellAddPromocode: UICollectionViewCell {
    @IBOutlet weak var vFrame: UIView!
    @IBOutlet weak var vFrameFront: UIView!
    @IBOutlet weak var lcWidth: NSLayoutConstraint!

    weak var delegate: CellAddPromocodeDelegate?

    func prepare(delegate: CellAddPromocodeDelegate) {
        self.delegate = delegate

        lcWidth.constant = UIScreen.main.bounds.width - 56

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.vFrame.updateShadow()
        }
    }

    @IBAction func addPromocode() {
        delegate?.addPromocode()
    }

    func massCancelClick() {
        vFrame.cancelClick()
        vFrameFront.cancelClick()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.vFrame.updateShadow()
    }
}
