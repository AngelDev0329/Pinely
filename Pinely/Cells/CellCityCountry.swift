//
//  CellCityCountry.swift
//  Pinely
//

import UIKit
// import MapKit

class CellCityCountry: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var vSeparator: UIView!

    func prepare(location: String, isLast: Bool) {
        lblTitle.text = location
        vSeparator.isHidden = isLast
    }
}
