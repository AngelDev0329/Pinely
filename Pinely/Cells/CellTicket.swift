//
//  CellTicket.swift
//  Pinely
//

import UIKit
import Kingfisher

protocol CellTicketDelegate: AnyObject {
    func buy(ticket: Ticket)
    func ticketAgotado(ticket: Ticket)
}

class CellTicket: UITableViewCell {
    @IBOutlet weak var ivRectangle: UIImageView!
    @IBOutlet weak var ivLogo: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblHourLimit: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblNoMoreEntries: UILabel!
    @IBOutlet weak var ivBuy: UIImageView!
    @IBOutlet weak var btnBuy: UIButton!
    @IBOutlet weak var btnEnded: UIButton!

    var ticket: Ticket!
    weak var delegate: CellTicketDelegate?

    let notificationFeedbackGenerator = UINotificationFeedbackGenerator()

    func prepare(ticket: Ticket, delegate: CellTicketDelegate?) {
        self.ticket = ticket
        self.delegate = delegate

        if (ticket.remaining ?? 0) <= 0 {
            ivLogo.image = nil
            ivLogo.backgroundColor = UIColor(hex: 0xFF3400, alpha: 1.0)
            lblNoMoreEntries.text = "¡No hay entradas!"
            lblNoMoreEntries.isHidden = false
        } else if let ratio = ticket.ratio,
                  ratio < 0.5 {
            ivLogo.image = nil
            ivLogo.backgroundColor = UIColor(hex: 0xFFCC00, alpha: 1.0)
            lblNoMoreEntries.text = "¡Últimas entradas!"
            lblNoMoreEntries.isHidden = false
        } else {
            ivLogo.backgroundColor = .clear
            if let urlString = ticket.urlThumb,
               let url = URL(string: urlString) {
                ivLogo.kf.setImage(with: url)
            }
           lblNoMoreEntries.isHidden = true
        }

        ivBuy.isHidden = (ticket.remaining ?? 0) <= 0
        btnBuy.isHidden = (ticket.remaining ?? 0) <= 0
        btnEnded.isHidden = (ticket.remaining ?? 0) > 0

        lblTitle.text = ticket.name ?? ""
        if let translation = AppDelegate.translation {
            lblPrice.text = (translation.getString("price_event_text") ?? "Precio:") + " " +
                (ticket.priceTicket?.toPrice() ?? "")
            lblHourLimit.text = (translation.getString("hour_limit_ticket") ?? "Hora límite:") +
                " " + ticket.getHourLimitString()

            btnEnded.setTitleFromTranslation("sold_out_text_button", translation)
            btnBuy.setTitleFromTranslation("buy_text_button", translation)
            
            if(lblNoMoreEntries.text == "¡No hay entradas!"){
                lblNoMoreEntries.text = (translation.getString("soldout_tickets_checkout") ?? lblNoMoreEntries.text)
            }
            else {
                lblNoMoreEntries.text = (translation.getString("last_tickets_checkout") ?? lblNoMoreEntries.text)
            }
            
        } else {
            lblPrice.text = "Precio: " + (ticket.priceTicket?.toPrice() ?? "")
            lblHourLimit.text = "Hora límite: " + ticket.getHourLimitString()
            btnBuy.setTitle("Comprar", for: .normal)
        }
        btnBuy.titleEdgeInsets.right = 20
    }

    @IBAction func buy() {
        notificationFeedbackGenerator.prepare()
        notificationFeedbackGenerator.notificationOccurred(.success)

        guard let delegate = self.delegate,
            let ticket = self.ticket
            else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            delegate.buy(ticket: ticket)
        }
    }

    @IBAction func agotado() {
        UIDevice.vibrate()
        AppSound.logOut.play()

        guard let delegate = self.delegate,
            let ticket = self.ticket
            else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            delegate.ticketAgotado(ticket: ticket)
        }
    }
}
