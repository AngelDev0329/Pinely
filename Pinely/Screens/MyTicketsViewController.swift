//
//  MyTicketsViewController.swift
//  Pinely
//

import UIKit
import SwipeView

class MyTicketsViewController: ViewController {
    @IBOutlet weak var btnActive: UIButton!
    @IBOutlet weak var btnInactive: UIButton!
    @IBOutlet weak var vActive: UIView!
    @IBOutlet weak var vInactive: UIView!

    @IBOutlet weak var svContent: SwipeView!

    @IBOutlet weak var aiLoader: UIActivityIndicatorView!

    var loaded = false

    var activeTickets: [HistoryTicket] = []
    var inactiveTickets: [HistoryTicket] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        loadData {
            self.aiLoader.stopAnimating()
        }

        if let translation = AppDelegate.translation {
            btnActive.setTitleFromTranslation("my_tickets_tab1", translation)
            btnInactive.setTitleFromTranslation("my_tickets_tab2", translation)
        }
    }

    private func loadData(delegate: @escaping () -> Void) {
        API.shared.getUserTickets { (tickets, error) in
            if let error = error {
                self.show(error: error, delegate: {
                    self.goBack()
                }, title: "Ups!")
                return
            }

            let dateNow = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateNowString = dateFormatter.string(from: dateNow)
            self.activeTickets = tickets.filter {
                guard let finishEvent = $0.finishEvent else { return false }
                let finishEventString = dateFormatter.string(from: finishEvent)
                return finishEventString >= dateNowString && !$0.isUsed()
            }
            self.inactiveTickets = tickets.filter {
                guard let finishEvent = $0.finishEvent else { return false }
                let finishEventString = dateFormatter.string(from: finishEvent)
                return finishEventString < dateNowString || $0.isUsed()
            }
            self.loaded = true
            self.svContent.isHidden = false
            self.svContent.reloadData()
            delegate()
        }
    }

    @IBAction func showActive() {
        showActiveTab()
        svContent.scrollToItem(at: 0, duration: 0.3)
    }

    private func showActiveTab() {
        btnActive.setTitleColor(UIColor(named: "MainForegroundColor"), for: .normal)
        btnInactive.setTitleColor(UIColor(hex: 0x7B7B7B)!, for: .normal)
        vActive.isHidden = false
        vInactive.isHidden = true
    }

    @IBAction func showInactive() {
        showInactiveTab()
        svContent.scrollToItem(at: 1, duration: 0.3)
    }

    private func showInactiveTab() {
        btnActive.setTitleColor(UIColor(hex: 0x7B7B7B)!, for: .normal)
        btnInactive.setTitleColor(UIColor(named: "MainForegroundColor"), for: .normal)
        vActive.isHidden = true
        vInactive.isHidden = false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let ticketQRVC = segue.destination as? TicketQRViewController,
           let saleInfo = sender as? (SaleInfo, String?) {
            ticketQRVC.saleInfo = saleInfo.0
            ticketQRVC.piReference = saleInfo.1
        }
    }
}

extension MyTicketsViewController: CellHistoryTicketDelegate {
    func historyTicketSelected(historyTicket: HistoryTicket?) {
        guard let piReference = historyTicket?.piReference else {
            return
        }

        let loading = BlurryLoadingView.showAndStart()
        API.shared.checkInformationTicket(piReference: piReference) { (saleInfo, error) in
            loading.stopAndHide()
            if let error = error {
                self.show(error: error)
            } else if saleInfo == nil {
                self.showError("Incorrect pi_reference")
            } else {
                self.performSegue(withIdentifier: "TicketQR", sender: (saleInfo, piReference))
            }
        }
    }
}

extension MyTicketsViewController: SwipeViewDataSource, SwipeViewDelegate {
    func numberOfItems(in swipeView: SwipeView!) -> Int {
        2
    }

    func swipeView(_ swipeView: SwipeView!, viewForItemAt index: Int, reusing view: UIView!) -> UIView! {
        let myTicketsView = (view as? MyTicketsView) ?? MyTicketsView(frame: swipeView.bounds)
        myTicketsView.prepare(tabIndex: index, tickets: (index == 0) ? activeTickets : inactiveTickets, delegate: self)
        return myTicketsView
    }

    func swipeViewCurrentItemIndexDidChange(_ swipeView: SwipeView!) {
        if swipeView.currentItemIndex == 0 {
            showActiveTab()
        } else {
            showInactiveTab()
        }
    }
}
