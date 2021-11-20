//
//  ReaderSalesViewController.swift
//  Pinely
//

import UIKit

class ReaderSalesViewController: ViewController {
    @IBOutlet weak var tvSales: UITableView!
    @IBOutlet weak var aiLoading: UIActivityIndicatorView!

    var titles = ["*Entradas vendidas en total", "*Entradas por validar", "*Entradas validadas", "*Entradas rechazadas"]
    var itemSingular = ["vendida", "sin validar", "validada", "rechazada"]
    var itemPlural = ["vendidas", "sin validar", "validadas", "rechazadas"]
    var sales: [Any] = []
    var eventId: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
    }

    fileprivate func buildRows(_ sales: [EventSaleSummary]) {
        self.sales = [self.titles[0]]
        var salesCount = 0
        sales.forEach {
            let item = ($0.totalSales ?? 0) == 1 ? self.itemSingular[0] : self.itemPlural[0]
            self.sales.append(($0.name ?? "No name", $0.totalSales ?? 0, item))
            salesCount += 1
        }
        if salesCount == 0 {
            self.sales.append("No se han vendido entradas para este evento aun.")
        }
        self.sales.append("")
        self.sales.append(self.titles[1])
        salesCount = 0
        sales.forEach {
            let count = ($0.totalSales ?? 0) - ($0.totalValidated ?? 0) - ($0.totalRejected ?? 0)
            let item = count == 1 ? self.itemSingular[1] : self.itemPlural[1]
            self.sales.append(($0.name ?? "No name", count, item))
            salesCount += 1
        }
        if salesCount == 0 {
            self.sales.append("No existen entradas pendientes de validar para este evento.")
        }
        self.sales.append("")
        self.sales.append(self.titles[2])
        salesCount = 0
        sales.forEach {
            let item = ($0.totalValidated ?? 0)
            == 1 ? self.itemSingular[2] : self.itemPlural[2]
            self.sales.append(($0.name ?? "No name", ($0.totalValidated ?? 0), item))
            salesCount += 1
        }
        if salesCount == 0 {
            self.sales.append("No existen entradas validadas para este evento.")
        }
        self.sales.append("")
        self.sales.append(self.titles[3])
        salesCount = 0
        sales.forEach {
            let item = ($0.totalRejected ?? 0) == 1 ? self.itemSingular[3] : self.itemPlural[3]
            self.sales.append(($0.name ?? "No name", $0.totalRejected ?? 0, item))
            salesCount += 1
        }
        if salesCount == 0 {
            self.sales.append("No existen entradas rechazadas para este evento.")
        }
    }

    private func loadData() {
        API.shared.getSalesResume(eventId: eventId) { (sales, error) in
            if let error = error {
                self.show(error: error, delegate: {
                    self.goBack()
                }, title: "Oops!")
                self.aiLoading.stopAnimating()
                return
            }

            self.buildRows(sales)
            self.tvSales.reloadData()
            self.aiLoading.stopAnimating()
        }
    }
}

extension ReaderSalesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sales.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = sales[indexPath.row]
        if let sale = item as? (String, Int, String) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SaleSummary", for: indexPath) as? CellSaleSummary
            var isLast = indexPath.row >= sales.count - 1
            if !isLast {
                isLast = !(sales[indexPath.row + 1] is (String, Int, String))
            }
            cell?.prepare(name: sale.0, amount: sale.1, item: sale.2, isLast: isLast)
            return cell ?? UITableViewCell()
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SaleSummaryTitle", for: indexPath)
            if let label = cell.viewWithTag(1) as? UILabel {
                var text = "\(item)"
                if text.hasPrefix("*") {
                    text = String(text[1...])
                    label.font = AppFont.semiBold[10]
                } else {
                    label.font = AppFont.regular[10]
                }
                label.text = text
            }
            return cell
        }
    }
}
