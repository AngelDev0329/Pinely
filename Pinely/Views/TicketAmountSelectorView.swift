//
//  TicketAmountSelectorView.swift
//  Pinely
//

import UIKit
import FirebaseAnalytics

protocol TicketAmountSelectorViewDelegate: AnyObject {
    func ticketsSelected(ticket: Ticket, amount: Int)
    func ticketsSelectionDialogClosed()
}

class TicketAmountSelectorView: UIView {
    @IBOutlet var contentView: UIView!

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTicketAmount: UILabel!
    @IBOutlet weak var lcSelectorBottom: NSLayoutConstraint!
    @IBOutlet weak var lblSelect: UILabel!

    var currentAmount: Int = 1 {
        didSet {
            lblTicketAmount.text = "\(currentAmount)"
        }
    }

    var ticket: Ticket! {
        didSet {
            currentAmount = ticket.amount
            if currentAmount < 1 {
                currentAmount = 1
            }
        }
    }

    weak var delegate: TicketAmountSelectorViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        let nibName = "TicketAmountSelectorView"
        Bundle.main.loadNibNamed(nibName, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    func appear() {
        lblTitle.setTextFromTranslation("tickets_selection_title")
        lblSelect.setTextFromTranslation("tickets_selection_button")

        lcSelectorBottom.constant = -500
        self.layoutIfNeeded()

        contentView.alpha = 0.0

        lcSelectorBottom.constant = -30
        UIView.animate(withDuration: 0.3) {
            self.contentView.alpha = 1.0
            self.layoutIfNeeded()
        } completion: { _ in
            // No action required
        }
    }

    @IBAction func closeDialog() {
        lcSelectorBottom.constant = -500

        UIView.animate(withDuration: 0.3) {
            self.contentView.alpha = 0.0
            self.contentView.layoutIfNeeded()
        } completion: { _ in
            self.removeFromSuperview()
            self.delegate?.ticketsSelectionDialogClosed()
        }
    }

    @IBAction func selectAndContinue() {
        UIDevice.vibrate()

        Analytics.logEvent("add_to_cart", parameters: [
            "id_ticket": self.ticket.id ?? -1,
            "name_ticket": self.ticket.name ?? "" ,
            "quantity": self.currentAmount
        ])
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.delegate?.ticketsSelected(ticket: self.ticket, amount: self.currentAmount)
            self.closeDialog()
        }
    }

    @IBAction func increaseAmount() {
        UIDevice.vibrate()

        let maxAmount = ticket.remaining ?? 100
        if currentAmount >= maxAmount || currentAmount >= 20 {
            return
        }

        currentAmount += 1
        lblTicketAmount.text = "\(currentAmount)"
    }

    @IBAction func decreaseAmount() {
        UIDevice.vibrate()

        if currentAmount > 1 {
            currentAmount -= 1
            lblTicketAmount.text = "\(currentAmount)"
        }
    }

    static func showAndStart(ticket: Ticket, delegate: TicketAmountSelectorViewDelegate) -> TicketAmountSelectorView {
        let dialog = TicketAmountSelectorView(frame: UIScreen.main.bounds)
        dialog.delegate = delegate
        dialog.ticket = ticket
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.window?.addSubview(dialog)
        dialog.appear()
        return dialog
    }
}
