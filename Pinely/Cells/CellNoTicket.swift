//
//  CellNoTicket.swift
//  Pinely
//

import UIKit
import Kingfisher

class CellNoTicket: UITableViewCell {
    @IBOutlet weak var lblNoItemMessage: UILabel!

    func prepare() {
        if let translation = AppDelegate.translation {
            lblNoItemMessage.text =  translation.getString("event_without_tickets") ?? lblNoItemMessage.text
        }
    }
}
