//
//  CellSaleSummary.swift
//  Pinely
//

import UIKit

class CellSaleSummary: UITableViewCell {
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var vLine: UIView!

    func prepare(name: String, amount: Int, item: String, isLast: Bool) {
        lblName.text = name
        lblAmount.text = "\(amount) \(item)"
        vLine.isHidden = isLast
    }
}
