//
//  ReaderClientsViewController.swift
//  Pinely
//

import UIKit
import SwipeView
import SwiftEventBus

class ReaderClientsViewController: ViewController {
    @IBOutlet weak var cvStatuses: UICollectionView!
    @IBOutlet weak var aiLoading: UIActivityIndicatorView!

    @IBOutlet weak var svContent: SwipeView!

    var event: Event?
    var sales: [QRSale] = []
    var salesFiltered: [QRSale] = []
    var selectedTabIdx = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        SwiftEventBus.onMainThread(self, name: "readerUpdated") { [weak self] (_) in
            self?.loadData()
        }

        svContent.isHidden = true

        loadData {
            self.svContent.isHidden = false
        }
    }

    deinit {
        SwiftEventBus.unregister(self)
    }

    private func loadData(delegate: @escaping () -> Void = {
        // Default empty delegate
    }) {
        guard let eventId = event?.id else {
            return
        }

        API.shared.getQRTicketsForEvent(eventId: eventId) { (sales, error) in
            self.aiLoading.stopAnimating()

            if let error = error {
                self.show(error: error, delegate: {
                    self.goBack()
                }, title: "Oops!")
                return
            }

            self.sales = sales.filter { $0.status == .notValidated }
            self.sales.append(contentsOf: sales.filter { $0.status == .rejected })
            self.sales.append(contentsOf: sales.filter { $0.status == .mixed })
            self.sales.append(contentsOf: sales.filter { $0.status == .validated })
            self.cvStatuses.reloadData()
            self.filter()
            delegate()
        }
    }

    func filter(request: String? = nil) {
        self.salesFiltered = sales
        if let request = request,
            !request.isEmpty {
            let requestLc = request.lowercased().folding(options: .diacriticInsensitive, locale: .current)
            self.salesFiltered = salesFiltered
                .filter { $0.nameClient?.lowercased()
                    .folding(options: .diacriticInsensitive, locale: .current)
                    .contains(requestLc) == true
                }
        }

        cvStatuses.reloadData()
        svContent.reloadData()
    }

    @IBAction func showSales() {
        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.performSegue(withIdentifier: "ReaderSales", sender: self)
        }
    }

    @IBAction func scanTicket() {
        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let loading = BlurryLoadingView.showAndStart()
            API.shared.getReaderKey(idLocal: self.event?.idLocal ?? -1) { (licenseKey, error) in
                loading.stopAndHide()
                if let error = error {
                    self.show(error: error)
                    return
                }

                self.performSegue(withIdentifier: "ReaderScan", sender: licenseKey)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? ReaderSalesViewController {
            if let eventId = self.event?.id {
                viewController.eventId = eventId
            }
        } else if let viewController = segue.destination as? ReaderEntryInfoViewController {
            if let sale = sender as? QRSale {
                viewController.sale = sale
                viewController.barcode = sale.QRCode
            }
            viewController.eventId = self.event?.id
        } else if let viewController = segue.destination as? ReaderScanViewController {
            viewController.eventId = self.event?.id
            if let licenseKey = sender as? String {
                viewController.licenseKey = licenseKey
            }
        }
    }
}

extension ReaderClientsViewController: UICollectionViewDelegate,
                                       UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        5
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Status", for: indexPath) as? CellStatus
        let count: Int
        switch indexPath.item {
        case 0: count = sales.count
        case 1: count = sales.filter { $0.status == .notValidated }.count
        case 2: count = sales.filter { $0.status == .validated }.count
        case 3: count = sales.filter { $0.status == .rejected }.count
        case 4: count = sales.filter { $0.status == .mixed }.count
        default: count = 0
        }
        cell?.prepare(statusIdx: indexPath.item, count: count, isSelected: selectedTabIdx == indexPath.item)
        return cell ?? UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        selectedTabIdx = indexPath.item

        let contentOffset = cvStatuses.contentOffset

        cvStatuses.reloadData()
        cvStatuses.layoutIfNeeded()

        DispatchQueue.main.async { [weak self] in
            self?.cvStatuses.setContentOffset(contentOffset, animated: false)
        }

        svContent.scrollToItem(at: selectedTabIdx, duration: 0.3)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let count: Int
        switch indexPath.item {
        case 0: count = sales.count
        case 1: count = sales.filter { $0.status == .notValidated }.count
        case 2: count = sales.filter { $0.status == .validated }.count
        case 3: count = sales.filter { $0.status == .rejected }.count
        case 4: count = sales.filter { $0.status == .mixed }.count
        default: count = 0
        }
        let status = CellStatus.statuses[indexPath.item] + " (\(count))"
        let font = AppFont.semiBold[10]
        return CGSize(width: status.width(withConstrainedHeight: 100, font: font) + 50, height: 40)
    }
}

extension ReaderClientsViewController: UITextFieldDelegate {
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

extension ReaderClientsViewController: CellTicketSaleDelegate {
    func entrySelected(sale: QRSale) {
//        let sb = self.storyboard!
//        let vc = sb.instantiateViewController(withIdentifier: "ReaderEntryInfo") as! ReaderEntryInfoViewController
//        vc.modalTransitionStyle = .coverVertical
//        vc.modalPresentationStyle = .pageSheet //.formSheet
//        vc.sale = sale
//        vc.barcode = sale.QRCode
//        navigationController?.present(vc, animated: true, completion: nil)

        self.performSegue(withIdentifier: "ReaderEntryInfo", sender: sale)
    }
}

extension ReaderClientsViewController: ReaderClientsTabViewDelegate {
    func refreshClients(delegate: @escaping () -> Void) {
        DispatchQueue.main.async {
            self.loadData(delegate: delegate)
        }
    }
}

extension ReaderClientsViewController: SwipeViewDelegate, SwipeViewDataSource {
    func numberOfItems(in swipeView: SwipeView!) -> Int {
        5
    }

    func swipeView(_ swipeView: SwipeView!, viewForItemAt index: Int, reusing view: UIView!) -> UIView! {
        let readerClientsTabView = (view as? ReaderClientsTabView) ?? ReaderClientsTabView(frame: swipeView.bounds)
        readerClientsTabView.backgroundColor = .clear
        readerClientsTabView.prepare(tabIndex: index, sales: salesFiltered, delegate: self)
        return readerClientsTabView
    }

    func swipeViewCurrentItemIndexDidChange(_ swipeView: SwipeView!) {
        selectedTabIdx = swipeView.currentItemIndex

        let contentOffset = cvStatuses.contentOffset

        cvStatuses.reloadData()
        cvStatuses.layoutIfNeeded()

        DispatchQueue.main.async { [weak self] in
            self?.cvStatuses.setContentOffset(contentOffset, animated: false)
        }
    }
}
