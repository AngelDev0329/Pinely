//
//  CellTag.swift
//  Pinely
//

import UIKit

class CellTag: UICollectionViewCell {
    @IBOutlet weak var vContainer: UIView!
    @IBOutlet weak var lblTitle: UILabel!

    func prepare(tagTitle: String, tagIndex: Int) {
        lblTitle.text = tagTitle.uppercased()
        vContainer.backgroundColor = CellTag.colors[tagIndex % CellTag.colors.count]
    }

    static let colors: [UIColor] = [
        UIColor(hex: 0x0090FF)!,
        UIColor(hex: 0x9A00FF)!
    ]
}
