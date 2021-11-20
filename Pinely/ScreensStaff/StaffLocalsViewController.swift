//
//  StaffEventsViewController.swift
//  Pinely
//

import UIKit
import SwiftEventBus

class StaffLocalsViewController: ViewController {
    @IBOutlet weak var cvLocals: UICollectionView!

    enum Mode {
        case edit
        case facturas
        case ventas
    }

    var mode = Mode.edit
    var loaded = false

    var locals: [Place] = []
    var localsFiltered: [Place] = []

    var canAdd: Bool {
        mode == .edit
    }
    var loading = true

    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()

        SwiftEventBus.onMainThread(self, name: "localsUpdates") { (_) in
            self.loaded = false
            self.loading = true
            self.cvLocals.reloadData()
            self.loadData()
        }
    }

    deinit {
        SwiftEventBus.unregister(self)
    }

    private func loadData() {
        API.shared.getLocalsForStaff { (locals, error) in
            self.loading = false
            if let error = error {
                self.cvLocals.reloadData()
                self.show(error: error)
            }

            self.locals = locals.compactMap { $0.place }
            self.filter(request: self.tfSearch?.text)
        }
    }

    func filter(request: String? = nil) {
        let query = request?.trimmingCharacters(in: .whitespacesAndNewlines) ??
            tfSearch?.textPrepared ?? ""
        if query.isEmpty {
            localsFiltered = locals
        } else {
            let queryPrepared = query.lowercased().folding(options: .diacriticInsensitive, locale: .current)
            localsFiltered = locals.filter {
                $0.name.lowercased().folding(options: .diacriticInsensitive, locale: .current).contains(queryPrepared)
            }
        }
        cvLocals.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let staffPlaceEditVC = segue.destination as? StaffPlaceEditViewController {
            staffPlaceEditVC.place = sender as? Place
        }
    }
}

extension StaffLocalsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = localsFiltered.count
        if canAdd {
            count += 1
        }
        if loading {
            count += 1
        }
        return count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let localIndex = canAdd ? (indexPath.item - 1) : indexPath.item
        if localIndex < 0 {
            // Add
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddPlace", for: indexPath) as? CellAddPlace
            cell?.prepare(delegate: self)
            return cell ?? UICollectionViewCell()
        } else if localIndex < localsFiltered.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Place", for: indexPath) as? CellPlace
            let place = localsFiltered[localIndex]
            // cell.prepare(event: local, delegate: self)
            cell?.prepare(place: place, delegate: self)
            return cell ?? UICollectionViewCell()
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Loading", for: indexPath)
            return cell
        }
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
}

extension StaffLocalsViewController: CellPlaceDelegate {
    func placeSelected(place: Place) {
        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            switch self.mode {
            case .edit:
                self.performSegue(withIdentifier: "PlaceEdit", sender: place)

            case .facturas:
                self.performSegue(withIdentifier: "Facturas", sender: place)

            case .ventas:
                self.performSegue(withIdentifier: "Ventas", sender: place)
            }
        }
    }
}

extension StaffLocalsViewController: CellAddPlaceDelegate {
    func addPlace() {
        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let loading = BlurryLoadingView.showAndStart()
            API.shared.checkIfCanSellTickets { (canSell, error) in
                loading.stopAndHide()
                if let error = error {
                    self.show(error: error)
                    return
                }

                if !canSell {
                    self.showError("error.accountNotReadyToSell".localized)
                    return
                }

                self.performSegue(withIdentifier: "AddPlace", sender: self)
            }
        }
    }
}

extension StaffLocalsViewController: UITextFieldDelegate {
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

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
           let textRange = Range(range, in: text) {
           let updatedText = text.replacingCharacters(in: textRange, with: string)
            self.filter(request: updatedText)
        }
        return true
    }
}
