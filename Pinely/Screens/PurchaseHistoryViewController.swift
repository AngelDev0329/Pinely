//
//  PurchaseHistoryViewController.swift
//  Pinely
//

import UIKit

class PurchaseHistoryViewController: ViewController {
    @IBOutlet weak var tvPurchases: UITableView!
    @IBOutlet weak var aiLoading: UIActivityIndicatorView!

    var purchases: [Purchase] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
    }

    private func loadData() {
        API.shared.getPurchaseHistory { (purchases, error) in
            self.aiLoading.stopAnimating()
            if let error = error {
                self.show(error: error) {
                    self.goBack()
                }
            } else {
                self.purchases = purchases
                self.tvPurchases.reloadData()
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let transactionInfoVC = segue.destination as? TransactionInfoViewController,
           let purchase = sender as? Purchase {
            transactionInfoVC.purchase = purchase
        }
    }
}

extension PurchaseHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        purchases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Purchase", for: indexPath) as? CellPurchaseInHistory
        cell?.prepare(purchase: purchases[indexPath.row])
        return cell ?? UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "transactionInfo", sender: purchases[indexPath.row])
    }
}
