//
//  CellPurchaseInHistory.swift
//  Pinely
//

import UIKit
import Kingfisher

class CellPurchaseInHistory: UITableViewCell {
    @IBOutlet weak var ivLogo: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblDate: UILabel!

    func prepare(purchase: Purchase) {
        if let urlString = purchase.avatarUrl,
            let url = URL(string: urlString) {
            ivLogo.kf.setImage(with: url)
        } else {
            ivLogo.image = nil
        }

        lblTitle.text = purchase.name
        lblPrice.text = purchase.amount?.toPrice() ?? ""

        var secondsFromGMT = TimeZone.current.secondsFromGMT()
        if let timeZoneValue = purchase.timeZoneValue,
           timeZoneValue.count == 6 {
            let hours = Int(timeZoneValue[1...2]) ?? 0
            let minutes = Int(timeZoneValue[3...4]) ?? 0
            secondsFromGMT = (hours * 60 + minutes) * 60
            if timeZoneValue[0] == "-" {
                secondsFromGMT = -secondsFromGMT
            }
        }

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: secondsFromGMT)
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        if let date = purchase.date {
            lblDate.text = dateFormatter.string(from: date)
        } else {
            lblDate.text = ""
        }
    }
}
