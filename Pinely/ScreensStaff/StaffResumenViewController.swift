//
//  StaffResumenViewController.swift
//  Pinely
//

import UIKit

class StaffResumenViewController: ViewController {
    @IBOutlet weak var tvSales: UITableView!
    @IBOutlet weak var aiLoading: UIActivityIndicatorView!

    var titles = ["Entradas vendidas", "Entradas reembolsadas", "Entradas rechazadas en puerta", "Documentos por códigos promocionales"]
    var itemSingular = ["vendida", "reembolsada", "sin validar", "rechazada", "canjeada"]
    var itemPlural = ["vendidas", "reembolsadas", "sin validar", "rechazadas", "canjeadas"]
    var rows: [Any] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
    }

    private func loadData() {
        let eventId = 3
        API.shared.getSalesResume(eventId: eventId) { (sales, error) in
            if let error = error {
                self.show(error: error, delegate: {
                    self.goBack()
                }, title: "Oops!")
                self.aiLoading.stopAnimating()
                return
            }

            self.rows = [self.titles[0]]
            sales.forEach {
                let item = ($0.totalSales ?? 0) == 1 ? self.itemSingular[0] : self.itemPlural[0]
                self.rows.append(($0.name ?? "No name", $0.totalSales ?? 0, item))
            }
            self.rows.append("")

            self.rows.append(self.titles[1])
            sales.forEach {
                let count = ($0.totalSales ?? 0) - ($0.totalValidated ?? 0) - ($0.totalRejected ?? 0)
                let item = count == 1 ? self.itemSingular[1] : self.itemPlural[1]
                self.rows.append(($0.name ?? "No name", count, item))
            }
            self.rows.append("")

            self.rows.append(self.titles[2])
            sales.forEach {
                let item = ($0.totalValidated ?? 0)
                     == 1 ? self.itemSingular[2] : self.itemPlural[2]
                self.rows.append(($0.name ?? "No name", ($0.totalValidated ?? 0), item))
            }
            self.rows.append("")

            self.rows.append(self.titles[3])
            self.rows.append(("WELCOME", 160, self.itemPlural[3]))
            self.rows.append(("PARTYHOUSE", 160, self.itemPlural[3]))
            self.rows.append(("HOUSETOUR", 160, self.itemPlural[3]))

            self.rows.append("")
            self.rows.append("")
            self.rows.append("")

            self.tvSales.reloadData()
            self.aiLoading.stopAnimating()
        }
    }
}

extension StaffResumenViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = rows[indexPath.row]
        if let sale = item as? (String, Int, String) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SaleSummary", for: indexPath) as? CellSaleSummary
            cell?.prepare(name: sale.0, amount: sale.1, item: sale.2, isLast: indexPath.row == rows.count - 1)
            return cell ?? UITableViewCell()
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SaleSummaryTitle", for: indexPath)
            if let label = cell.viewWithTag(1) as? UILabel {
                label.text = "\(item)"
            }
            return cell
        }
    }
}
