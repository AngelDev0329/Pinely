//
//  CellCountry.swift
//  Pinely
//

import UIKit

class CellCountry: UITableViewCell {
    @IBOutlet weak var ivFlag: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var vSeparator: UIView!

    func prepare(country: StaffCountry, isLast: Bool) {
        lblName.text = country.getName()

        if let flag = country.flagUrl,
           let flagUrl = URL(string: flag) {
            ivFlag.kf.setImage(with: flagUrl)
        } else {
            ivFlag.image = nil
        }

        vSeparator.isHidden = isLast
    }
}
