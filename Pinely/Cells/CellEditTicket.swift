//
//  CellEditTicket.swift
//  Pinely
//

import UIKit
import Kingfisher

protocol CellEditTicketDelegate: AnyObject {
    func edit(ticket: Ticket)
}

class CellEditTicket: UITableViewCell {
    @IBOutlet weak var ivLogo: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var ivBuy: UIImageView!
    @IBOutlet weak var btnBuy: UIButton!

    var ticket: Ticket!
    weak var delegate: CellEditTicketDelegate?

    func prepare(ticket: Ticket, delegate: CellEditTicketDelegate?) {
        self.ticket = ticket
        self.delegate = delegate

        lblTitle.text = ticket.name ?? ""
        lblPrice.text = "Precio: " + (ticket.priceTicket?.toPrice() ?? "")

        if let urlString = ticket.urlThumb,
           let url = URL(string: urlString) {
            ivLogo.kf.setImage(with: url)
        }
    }

    @IBAction func buy() {
        UIDevice.vibrate()
        guard let delegate = self.delegate,
            let ticket = self.ticket
            else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            delegate.edit(ticket: ticket)
        }
    }
}
