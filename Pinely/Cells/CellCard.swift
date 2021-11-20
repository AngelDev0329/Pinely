//
//  CellCard.swift
//  Pinely
//

import UIKit

class CellCard: UICollectionViewCell {
    @IBOutlet weak var ivIcon: UIImageView!
    @IBOutlet weak var lblHiddenNumber: UILabel!
    @IBOutlet weak var lblNumber: UILabel!
    @IBOutlet weak var vSeparationLine: UIView!

    func prepare(card: Card, isLast: Bool) {
        vSeparationLine.isHidden = isLast
        let number = card.number ?? card.last4 ?? ""
        switch card.type ?? .masterCard {
        case .apple:
            lblNumber.text = "Apple Pay"
            lblHiddenNumber.text = ""

        case .bitcoin:
            lblNumber.text = "Bitcoin"
            lblHiddenNumber.text = ""

        case .paypal:
            lblNumber.text = "PayPal"
            lblHiddenNumber.text = ""

        default:
            let lastDigits = String(number[(number.count-4)...])
            lblNumber.text = lastDigits
            lblHiddenNumber.text = "•••• "
        }

        ivIcon.image = card.type?.image
    }
}
