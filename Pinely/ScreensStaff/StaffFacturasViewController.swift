//
//  StaffFacturasViewController.swift
//  Pinely
//

import UIKit

class StaffFacturasViewController: ViewController {
    @IBOutlet weak var cvStatuses: UICollectionView!
    @IBOutlet weak var cvFacturas: UICollectionView!
    @IBOutlet weak var aiLoading: UIActivityIndicatorView!

    var facturas: [Factura] = []
    var facturasFiltered: [Factura] = []
    var selectedTabIdx = 0

    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        cvFacturas.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshClients(_:)), for: .valueChanged)

        loadData()
    }

    private func loadData(delegate: @escaping () -> Void = {
        // Default empty delegate
    }) {
        facturas = [
            Factura(code: "FACTURA-1", status: "paid", paymentDate: Date()),
            Factura(code: "FACTURA-2", status: "pending", paymentDate: Date()),
            Factura(code: "FACTURA-3", status: "paid", paymentDate: Date()),
            Factura(code: "FACTURA-4", status: "pending", paymentDate: Date())
        ]

        self.aiLoading.stopAnimating()
        self.cvStatuses.reloadData()
        self.filter()
        delegate()
    }

    @objc private func refreshClients(_ sender: Any) {
        DispatchQueue.main.async {
            AppSound.uiRefreshFeed.play()
            self.loadData {
                self.refreshControl.endRefreshing()
            }
        }
    }

    func filter(request: String? = nil) {
        switch selectedTabIdx {
        case 0: self.facturasFiltered = self.facturas
        case 1: self.facturasFiltered = self.facturas.filter { $0.status == "paid" }
        case 2: self.facturasFiltered = self.facturas.filter { $0.status == "pending" }
        default: self.facturasFiltered = []
        }
        if let request = request,
            !request.isEmpty {
            let requestLc = request.lowercased().folding(options: .diacriticInsensitive, locale: .current)
            self.facturasFiltered = facturasFiltered
                .filter { $0.code?.lowercased()
                    .folding(options: .diacriticInsensitive, locale: .current)
                    .contains(requestLc) == true
                }
        }
        cvFacturas.reloadData()
    }
}

extension StaffFacturasViewController: UICollectionViewDelegate,
                                       UICollectionViewDataSource,
                                       UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case cvStatuses:
            return 3

        case cvFacturas:
            return facturasFiltered.count

        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case cvStatuses:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FacturaStatus", for: indexPath) as? CellFacturaStatus
            let count: Int
            switch indexPath.item {
            case 0: count = facturas.count
            case 1: count = facturas.filter { $0.status == "paid" }.count
            case 2: count = facturas.filter { $0.status == "pending" }.count
            default: count = 0
            }
            cell?.prepare(statusIdx: indexPath.item, count: count, isSelected: selectedTabIdx == indexPath.item)
            return cell ?? UICollectionViewCell()

        case cvFacturas:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Factura", for: indexPath) as? CellFactura
            cell?.prepare(factura: facturasFiltered[indexPath.item], delegate: self)
            return cell ?? UICollectionViewCell()

        default:
            return UICollectionViewCell()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        switch collectionView {
        case cvStatuses:
            selectedTabIdx = indexPath.item

            filter()

            let contentOffset = cvStatuses.contentOffset

            cvStatuses.reloadData()
            cvStatuses.layoutIfNeeded()

            DispatchQueue.main.async { [weak self] in
                self?.cvStatuses.setContentOffset(contentOffset, animated: false)
            }

        case cvFacturas:
            break

        default:
            break
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case cvStatuses:
            let count: Int
            switch indexPath.item {
            case 0: count = facturas.count
            case 1: count = facturas.filter { $0.status == "paid" }.count
            case 2: count = facturas.filter { $0.status == "pending" }.count
            default: count = 0
            }
            let status = CellFacturaStatus.statuses[indexPath.item] + " (\(count))"
            let font = AppFont.semiBold[10]
            return CGSize(width: status.width(withConstrainedHeight: 100, font: font) + 50, height: 40)

        case cvFacturas:
            return CGSize(width: UIScreen.main.bounds.width - 40, height: 90)

        default:
            return CGSize()
        }
    }

}

extension StaffFacturasViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIDevice.vibrate()
        hideSearchBarPlaceholder()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text ?? "").isEmpty {
            showSearchBarPlaceholder()
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if let text = textField.text,
           let textRange = Range(range, in: text) {
           let updatedText = text.replacingCharacters(in: textRange, with: string)
            self.filter(request: updatedText)
        }
        return true
    }
}

extension StaffFacturasViewController: CellFacturaDelegate {
    func facturaSelected(factura: Factura) {
        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.performSegue(withIdentifier: "StaffResumen", sender: factura)
        }
    }
}

extension StaffFacturasViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == cvFacturas {
            cvFacturas.visibleCells.forEach {
                ($0 as? CellFactura)?.massCancelClick()
            }
        }
    }
}
