//
//  CellCountryCode.swift
//  Pinely
//

import UIKit

class CellCountryCode: UITableViewCell {
    @IBOutlet weak var ivFlag: UIImageView!
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var vLine: UIView!

    func prepare(country: [String: Any], isLast: Bool) {
        let nameEs = country.getString("es") ?? ""
        let code = country.getString("code") ?? ""
        ivFlag.image = country["countryImage"] as? UIImage
        lblCountry.text = "\(nameEs) (+\(code))"
        vLine.isHidden = isLast
    }
}
