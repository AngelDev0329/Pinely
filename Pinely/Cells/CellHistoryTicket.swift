//
//  CellHistoryTicket.swift
//  Pinely
//

import UIKit

protocol CellHistoryTicketDelegate: AnyObject {
    func historyTicketSelected(historyTicket: HistoryTicket?)
}

class CellHistoryTicket: UICollectionViewCell {
    @IBOutlet weak var vContainer: UIView!
    @IBOutlet weak var ivBackground: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var lblCount: UILabel!

    var historyTicket: HistoryTicket?
    weak var delegate: CellHistoryTicketDelegate?

    func prepare(historyTicket: HistoryTicket, delegate: CellHistoryTicketDelegate?) {
        vContainer.transform = CGAffineTransform(scaleX: 1, y: 1)
        lblTitle.text = historyTicket.name ?? ""
        lblSubTitle.text = historyTicket.nameLocal ?? ""
        lblCount.text = "x\(historyTicket.number)"
        if let urlString = historyTicket.urlThumb,
            !urlString.isEmpty,
            let url = URL(string: urlString) {
            ivBackground.kf.setImage(with: url)
        }

        self.historyTicket = historyTicket
        self.delegate = delegate
    }

    @IBAction func placeSelected() {
        UIDevice.vibrate()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            if let historyTicket = self?.historyTicket {
                self?.delegate?.historyTicketSelected(historyTicket: historyTicket)
            }
        }
    }
}
