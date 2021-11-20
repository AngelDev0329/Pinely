//
//  CellQRInfoRow.swift
//  Pinely
//

import UIKit

class CellQRInfoRow: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblValue: UILabel!
    @IBOutlet weak var vLine: UIView!

    func prepare(title: String, value: String, color: UIColor?, isLast: Bool) {
        let safeColor = color ?? UIColor(named: "MainForegroundColor")
        lblTitle.text = "\(title):"
        lblValue.text = value
        lblValue.textColor = safeColor
        vLine.isHidden = isLast
    }
}
