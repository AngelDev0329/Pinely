//
//  CellAddTicket.swift
//  Pinely
//

import UIKit
import Kingfisher

protocol CellAddTicketDelegate: AnyObject {
    func addTicket()
}

class CellAddTicket: UITableViewCell {
    weak var delegate: CellAddTicketDelegate?

    func prepare(delegate: CellAddTicketDelegate?) {
        self.delegate = delegate
    }

    @IBAction func addNew() {
        UIDevice.vibrate()
        guard let delegate = self.delegate
            else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            delegate.addTicket()
        }
    }
}
