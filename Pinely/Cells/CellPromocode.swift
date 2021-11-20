//
//  CellPromocode.swift
//  Pinely
//

import UIKit
import FirebaseStorage

protocol CellPromocodeDelegate: AnyObject {
    func promocodeSelected(promocode: Promocode)
}

class CellPromocode: UICollectionViewCell {
    @IBOutlet weak var ivPicture: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblUseTimes: UILabel!
    @IBOutlet weak var vFrame: UIView!
    @IBOutlet weak var vFrameFront: UIView!
    @IBOutlet weak var vAvatarShade: UIView!
    @IBOutlet weak var lcWidth: NSLayoutConstraint!

    var promocode: Promocode?
    weak var delegate: CellPromocodeDelegate?

    func prepare(promocode: Promocode, delegate: CellPromocodeDelegate) {
        self.promocode = promocode
        self.delegate = delegate

        lcWidth.constant = UIScreen.main.bounds.width - 56
        lblName.font = AppFont.semiBold[10]
        lblStatus.font = AppFont.regular[10]
        lblUseTimes.font = AppFont.regular[10]
        let discount = promocode.quantity
        let discountString = String(format: "%d.%02d€", discount / 100, discount % 100)
        lblName.text = (promocode.code ?? "") + " (\(discountString))"
        lblUseTimes.text = "Canjeado: \(promocode.useTimes) veces"

        switch promocode.status {
        case "enabled":
            lblStatus.text = "Activo"
            lblStatus.textColor = UIColor(hex: 0x03E218)!

        case "disabled":
            lblStatus.text = "Eliminado"
            lblStatus.textColor = UIColor(hex: 0xFF0000)!

        default:
            lblStatus.text = "?"
            lblStatus.textColor = .black
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.vFrame.updateShadow()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.vFrame.updateShadow()
    }

    @IBAction func promocodeSelected() {
        if let promocode = self.promocode {
            delegate?.promocodeSelected(promocode: promocode)
        }
    }

    func massCancelClick() {
        vFrame.cancelClick()
        vFrameFront.cancelClick()
    }
}
