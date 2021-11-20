//
//  MyTicketsView.swift
//  Pinely
//

import UIKit

class MyTicketsView: UIView {
    @IBOutlet var contentView: UIView!

    @IBOutlet weak var cvTickets: UICollectionView!
    @IBOutlet weak var lblNoEntries: UILabel!

    var tabIndex = 0
    var tickets: [HistoryTicket] = []
    weak var delegate: CellHistoryTicketDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        let nibName = "MyTicketsView"
        Bundle.main.loadNibNamed(nibName, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        cvTickets.register(UINib(nibName: "CellHistoryTicket", bundle: nil), forCellWithReuseIdentifier: "Ticket")
        cvTickets.showsHorizontalScrollIndicator = false
        cvTickets.showsVerticalScrollIndicator = false
    }

    func prepare(tabIndex: Int, tickets: [HistoryTicket], delegate: CellHistoryTicketDelegate) {
        self.tabIndex = tabIndex

        let sorted = tickets.sorted { $0.id > $1.id }

        self.tickets = sorted
        self.delegate = delegate

        cvTickets.reloadData()
    }
}

extension MyTicketsView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let amount = tickets.count

        if let translation = AppDelegate.translation {
            if tabIndex == 0 {
                // Active
                lblNoEntries.text = translation.getString("my_tickets_any_ticket")  ?? "Tu cuenta no tiene entradas :("
            } else {
                // Inactive
                lblNoEntries.text = translation.getString("my_tickets_exchanges_yet") ?? "No tienes entradas canjeadas aun"
            }
        } else {
            if tabIndex == 0 {
                // Active
                lblNoEntries.text = "Tu cuenta no tiene entradas :("
            } else {
                // Inactive
                lblNoEntries.text = "No tienes entradas canjeadas aun"
            }
        }
        lblNoEntries.isHidden = amount > 0
        return amount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Ticket", for: indexPath) as? CellHistoryTicket
        cell?.prepare(historyTicket: tickets[indexPath.item], delegate: delegate)
        cell?.backgroundColor = .clear
        return cell ?? UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = UIScreen.main.bounds.width - 40
        let picWidth = cellWidth - 16
        let picHeight = picWidth * 145 / 368
        let cellHeight = picHeight + 16
        return CGSize(width: cellWidth, height: cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
    }
}
