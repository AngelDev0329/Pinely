//
//  CellTicketSale.swift
//  Pinely
//

import UIKit
import Kingfisher
import FirebaseStorage

protocol CellTicketSaleDelegate: AnyObject {
    func entrySelected(sale: QRSale)
}

class CellTicketSale: UICollectionViewCell {
    @IBOutlet weak var ivPicture: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var vFrame: UIView!
    @IBOutlet weak var vFrameFront: UIView!
    @IBOutlet weak var vAvatarShade: UIView!
    @IBOutlet weak var lcWidth: NSLayoutConstraint!
    @IBOutlet weak var vOutterCircle: UIView!
    @IBOutlet weak var vInnerCircle: UIView!

    var sale: QRSale?
    weak var delegate: CellTicketSaleDelegate?

    fileprivate func showSaleStatus(_ sale: QRSale) {
        switch sale.status {
        case .notValidated:
            lblStatus.text = "Sin validar"
            lblStatus.textColor = UIColor(named: "MainForegroundColor")
            vOutterCircle.backgroundColor = CellTicketSale.outterColors[0]
            vInnerCircle.backgroundColor = CellTicketSale.innerColors[0]

        case .validated:
            if sale.number == 1 {
                lblStatus.text = "Validada"
            } else {
                lblStatus.text = "Validadas"
            }
            lblStatus.textColor = CellTicketSale.innerColors[1]
            vOutterCircle.backgroundColor = CellTicketSale.outterColors[1]
            vInnerCircle.backgroundColor = CellTicketSale.innerColors[1]

        case .rejected:
            if sale.number == 1 {
                lblStatus.text = "Rechazada"
            } else {
                lblStatus.text = "Rechazadas"
            }
            lblStatus.textColor = CellTicketSale.innerColors[2]
            vOutterCircle.backgroundColor = CellTicketSale.outterColors[2]
            vInnerCircle.backgroundColor = CellTicketSale.innerColors[2]

        case .mixed:
            if sale.number == 1 {
                lblStatus.text = "Mixto"
            } else {
                lblStatus.text = "Mixtos"
            }
            lblStatus.textColor = CellTicketSale.innerColors[3]
            vOutterCircle.backgroundColor = CellTicketSale.outterColors[3]
            vInnerCircle.backgroundColor = CellTicketSale.innerColors[3]
        }
    }

    func prepare(sale: QRSale, delegate: CellTicketSaleDelegate?) {
        self.sale = sale
        self.delegate = delegate

        lcWidth.constant = UIScreen.main.bounds.width - 56
        lblName.text = sale.nameClient ?? ""
        if let urlString = sale.avatarClient {
            if urlString.starts(with: "http://") || urlString.starts(with: "https://"),
                let avatarUrl = URL(string: urlString) {
                ivPicture.kf.setImage(with: avatarUrl)
            } else if urlString.starts(with: "gs://") {
                let storageRef = Storage.storage().reference(forURL: urlString)
                storageRef.downloadURL { [weak self] (downloadUrl, _) in
                    if let downloadUrl = downloadUrl {
                        self?.ivPicture.kf.setImage(with: downloadUrl)
                    } else {
                        self?.ivPicture.image = #imageLiteral(resourceName: "AvatarPinely")
                    }
                }
            } else {
                ivPicture.image = #imageLiteral(resourceName: "AvatarPinely")
            }
        } else {
            ivPicture.image = #imageLiteral(resourceName: "AvatarPinely")
        }

        showSaleStatus(sale)

        layoutIfNeeded()
        vFrame.updateShadow()
        vAvatarShade.updateShadow()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.vFrame.updateShadow()
            self.vAvatarShade.updateShadow()
        }

        massCancelClick()
    }

    func massCancelClick() {
        vFrame.cancelClick()
        vFrameFront.cancelClick()
    }

    @IBAction func selectEntry() {
        if let delegate = delegate,
            let sale = sale {
            UIDevice.vibrate()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                delegate.entrySelected(sale: sale)
            }
        }
    }

    static let outterColors: [UIColor] = [
        UIColor(hex: 0xD6D6D6)!,
        UIColor(hex: 0x78FF85)!,
        UIColor(hex: 0xFF9F9F)!,
        UIColor(hex: 0xFFD386)!
    ]

    static let innerColors: [UIColor] = [
        UIColor(hex: 0xB4B4B4)!,
        UIColor(hex: 0x03E218)!,
        UIColor(hex: 0xFF0000)!,
        UIColor(hex: 0xFFA200)!
    ]
}
