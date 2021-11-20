//
//  CellStatus.swift
//  Pinely
//

import UIKit

class CellStatus: UICollectionViewCell {
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var vFrame: UIView!

    static let statuses: [String] = [
        "Todas", "Sin validar", "Validadas", "Rechazadas", "Mixtos"
    ]

    func prepare(statusIdx: Int, count: Int, isSelected: Bool) {
        lblStatus.text = "\(CellStatus.statuses[statusIdx]) (\(count))"
        if isSelected {
            vFrame.borderWidth = 1.0
            vFrame.borderColor = UIColor.black
            lblStatus.font = AppFont.semiBold[10]
        } else {
            vFrame.borderWidth = 0.0
            vFrame.borderColor = UIColor.clear
            lblStatus.font = AppFont.regular[10]
        }
        vFrame.updateShadow()
        vFrame.alpha = 0.5

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.vFrame.updateShadow()
        }
    }
}
