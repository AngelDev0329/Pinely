//
//  CellTab.swift
//  Pinely
//

import UIKit

class CellTab: UICollectionViewCell {
    @IBOutlet weak var lblTabName: UILabel!
    @IBOutlet weak var vUnderline: UIView!

    func prepare(title: String, isSelected: Bool) {
        lblTabName.text = title
        vUnderline.isHidden = !isSelected

        if isSelected {
            lblTabName.textColor = UIColor(named: "TypeTabSelected")
        } else {
            lblTabName.textColor = UIColor(named: "TypeTabUnselected")
        }
    }
}
