//
//  CellStatus.swift
//  Pinely
//

import UIKit

class CellRange: UICollectionViewCell {
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var vFrame: UIView!

    static let ranges: [String] = [
        "Todos", "Lectores", "Revisores", "Administradores"
    ]

    func prepare(statusIdx: Int, count: Int, isSelected: Bool) {
        lblStatus.text = "\(CellRange.ranges[statusIdx]) (\(count))"
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
