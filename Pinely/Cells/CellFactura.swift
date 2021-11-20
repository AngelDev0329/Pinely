//
//  CellPromocode.swift
//  Pinely
//

import UIKit
import FirebaseStorage

protocol CellFacturaDelegate: AnyObject {
    func facturaSelected(factura: Factura)
}

class CellFactura: UICollectionViewCell {
    @IBOutlet weak var ivPicture: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblPaymentDate: UILabel!
    @IBOutlet weak var vFrame: UIView!
    @IBOutlet weak var vFrameFront: UIView!
    @IBOutlet weak var vAvatarShade: UIView!
    @IBOutlet weak var lcWidth: NSLayoutConstraint!

    var factura: Factura?
    weak var delegate: CellFacturaDelegate?

    func prepare(factura: Factura, delegate: CellFacturaDelegate) {
        self.factura = factura
        self.delegate = delegate

        lcWidth.constant = UIScreen.main.bounds.width - 56
        lblName.font = AppFont.semiBold[10]
        lblStatus.font = AppFont.regular[10]
        lblPaymentDate.font = AppFont.regular[10]

        lblName.text = factura.code ?? ""

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        if let paymentDate = factura.paymentDate {
            lblPaymentDate.text = "Fecha de pago: \(dateFormatter.string(from: paymentDate))"
        } else {
            lblPaymentDate.text = ""
        }

        switch factura.status {
        case "paid":
            lblStatus.text = "Pagada"
            lblStatus.textColor = UIColor(hex: 0x03E218)!

        case "pending":
            lblStatus.text = "Pendiente de pago"
            lblStatus.textColor = UIColor(hex: 0xE28C03)!

        default:
            lblStatus.text = "?"
            lblStatus.textColor = .black
        }
    }

    @IBAction func promocodeSelected() {
        if let factura = self.factura{
            delegate?.facturaSelected(factura: factura)
        }
    }

    func massCancelClick() {
        vFrame.cancelClick()
        vFrameFront.cancelClick()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        vFrame.updateShadow()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.vFrame.updateShadow()
        }
    }
}
