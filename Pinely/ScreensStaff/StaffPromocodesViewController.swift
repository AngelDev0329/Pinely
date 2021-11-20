//
//  StaffPromocodesViewController.swift
//  Pinely
//

import UIKit

class StaffPromocodesViewController: ViewController {
    @IBOutlet weak var cvStatuses: UICollectionView!
    @IBOutlet weak var cvPromocodes: UICollectionView!
    @IBOutlet weak var aiLoading: UIActivityIndicatorView!

    var promocodes: [Promocode] = []
    var promocodesFiltered: [Promocode] = []
    var selectedTabIdx = 0

    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        cvPromocodes.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshClients(_:)), for: .valueChanged)

        loadData()
    }

    private func loadData(delegate: @escaping () -> Void = {
        // Default empty delegate
    }) {
        promocodes = [
            Promocode(dict: [:]),
            Promocode(dict: [:]),
            Promocode(dict: [:]),
            Promocode(dict: [:])
        ]

        promocodes[0].code = "PROMOCODE"
        promocodes[0].status = "enabled"
        promocodes[0].useTimes = 1
        promocodes[0].quantity = 123

        promocodes[1].code = "ANOTHERCODE"
        promocodes[1].status = "enabled"
        promocodes[1].useTimes = 2
        promocodes[1].quantity = 423

        promocodes[2].code = "CODENUMBERTHREE"
        promocodes[2].status = "disabled"
        promocodes[2].useTimes = 3
        promocodes[2].quantity = 323

        promocodes[3].code = "THELASTCODE"
        promocodes[3].status = "enabled"
        promocodes[3].useTimes = 4
        promocodes[3].quantity = 223

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
        case 0: self.promocodesFiltered = self.promocodes
        case 1: self.promocodesFiltered = self.promocodes.filter { $0.status == "enabled" }
        case 2: self.promocodesFiltered = self.promocodes.filter { $0.status == "disabled" }
        default: self.promocodesFiltered = []
        }
        if let request = request,
            !request.isEmpty {
            let requestLc = request.lowercased().folding(options: .diacriticInsensitive, locale: .current)
            self.promocodesFiltered = promocodesFiltered
                .filter { $0.code?.lowercased()
                    .folding(options: .diacriticInsensitive, locale: .current)
                    .contains(requestLc) == true
                }
        }
        cvPromocodes.reloadData()
    }
}

extension StaffPromocodesViewController: UICollectionViewDelegate,
                                         UICollectionViewDataSource,
                                         UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case cvStatuses:
            return 3

        case cvPromocodes:
            return promocodesFiltered.count + 1

        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case cvStatuses:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PromocodeStatus", for: indexPath) as? CellPromocodeStatus
            let count: Int
            switch indexPath.item {
            case 0: count = promocodes.count
            case 1: count = promocodes.filter { $0.status == "enabled" }.count
            case 2: count = promocodes.filter { $0.status == "disabled" }.count
            default: count = 0
            }
            cell?.prepare(statusIdx: indexPath.item, count: count, isSelected: selectedTabIdx == indexPath.item)
            return cell ?? UICollectionViewCell()

        case cvPromocodes:
            if indexPath.item == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddPromocode", for: indexPath) as? CellAddPromocode
                cell?.prepare(delegate: self)
                return cell ?? UICollectionViewCell()
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Promocode", for: indexPath) as? CellPromocode
                cell?.prepare(promocode: promocodesFiltered[indexPath.item - 1], delegate: self)
                return cell ?? UICollectionViewCell()
            }

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

        case cvPromocodes:
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
            case 0: count = promocodes.count
            case 1: count = promocodes.filter { $0.status == "enabled" }.count
            case 2: count = promocodes.filter { $0.status == "disabled" }.count
            default: count = 0
            }
            let status = CellPromocodeStatus.statuses[indexPath.item] + " (\(count))"
            let font = AppFont.semiBold[10]
            return CGSize(width: status.width(withConstrainedHeight: 100, font: font) + 50, height: 40)

        case cvPromocodes:
            return CGSize(width: UIScreen.main.bounds.width - 40, height: 90)

        default:
            return CGSize()
        }
    }

}

extension StaffPromocodesViewController: UITextFieldDelegate {
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

extension StaffPromocodesViewController: CellPromocodeDelegate, CellAddPromocodeDelegate {
    func promocodeSelected(promocode: Promocode) {
        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {

        }
    }

    func addPromocode() {
        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {

        }
    }
}

extension StaffPromocodesViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == cvPromocodes {
            cvPromocodes.visibleCells.forEach {
                ($0 as? CellPromocode)?.massCancelClick()
                ($0 as? CellAddPromocode)?.massCancelClick()
            }
        }
    }
}
