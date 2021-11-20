//
//  ContributeViewController.swift
//  Pinely
//

import UIKit
import RSSelectionMenu

class ContributeViewController: ViewController {
    @IBOutlet weak var tfCategory: UITextField!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfLocation: UITextField!

    @IBOutlet weak var lTitle: UILabel!
    @IBOutlet weak var lLocation: UILabel!
    @IBOutlet weak var lButton: UILabel!

    @IBOutlet weak var lName: UILabel!
    @IBOutlet weak var lCategory: UILabel!

    var categories: [String] = [
        "Descatado",
        "Discotecas",
        "Eventos",
        "Chill Out"
    ]

    var categoriesApi: [String: String] = [
        "Descatado": "Destacado",
        "Discotecas": "Discotecas",
        "Eventos": "Bares&Pubs",
        "Chill Out": "Chill-Zone"
    ]

    var predefinedCategory: String?

    var citiesTowns: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        if let predefinedCategory = predefinedCategory {
            tfCategory.text = predefinedCategory
            tfCategory.isUserInteractionEnabled = false
        }

        tfLocation.text = CityOrTown.current?.getFullName() ?? ""

        City.shared.forEach { (city) in
            citiesTowns.append(city.getFullName())
            let towns = Town.shared.filter { $0.idCity == city.id }
            citiesTowns.append(contentsOf: towns.map { $0.getFullName() })
        }

        if !(tfLocation.text ?? "").isEmpty {
            tfLocation.isUserInteractionEnabled = false
        }

        if let translation = AppDelegate.translation {

            lTitle.text = translation.getString("suggestions_title") ?? "¡Teneis que añadir esto!"

            lName.text = translation.getString("suggestions_name") ?? "Nombre"
            lCategory.text = translation.getString("suggestions_category") ?? "Apellidos"
            lLocation.text = translation.getString("suggestions_ubication") ?? "Email"
            lButton.text =
                translation.getString("suggestions_button") ?? "Enviar sugerencia"

            tfName.placeholder = translation.getString("suggestions_name_placeholder") ?? "Introduce el nombre del lugar"

        }

    }

    private func showSuccessAlert() {
        if let translation = AppDelegate.translation {
            self.showSuccessCustom(
                title: translation.getString("suggestions_popup_title") ?? "¡Sugerencia enviada!",
                message: translation.getString("suggestions_popup_description") ?? "success.contributionInRevision".localized,
                button: translation.getString("suggestions_popup_button") ?? "Aceptar") {
                    self.goBack()
                }
        } else {
            self.showSuccess("success.contributionInRevision".localized) {
                self.goBack()
            }
        }
    }

    @IBAction func send() {
        view.endEditing(true)
        UIDevice.vibrate()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let name = self.tfName.text ?? ""

            if name.count < 3 {
                self.showWarning("Parece que el nombre no es correcto")
                return
            }

            let categoryText = self.tfCategory.text ?? ""
            var catApi = categoryText
            let pattern = "[^A-Za-z0-9]+"
            let catSearch = categoryText.replacingOccurrences(of: pattern, with: "", options: [.regularExpression])

            if let catKey = self.categoriesApi.keys
                .first(where: {
                    $0.replacingOccurrences(of: pattern, with: "", options: [.regularExpression]) == catSearch
                }) {
                catApi = self.categoriesApi[catKey] ?? categoryText
            }

            var selectedCityOrTown = CityOrTown.current
            if selectedCityOrTown == nil {
                let cityTownName = self.tfLocation.text ?? ""
                if let selectedTown = Town.shared.first(where: { (town) -> Bool in
                    town.getFullName() == cityTownName
                }) {
                    selectedCityOrTown = selectedTown
                } else if let selectedCity = City.shared.first(where: { (city) -> Bool in
                    city.getFullName() == cityTownName
                }) {
                    selectedCityOrTown = selectedCity
                }
            }

            if selectedCityOrTown == nil {
                self.showWarning("Parece que la ubicación no es correcta")
                return
            }

            var countryId = 0
            var cityId = 0
            var townId: Int?

            if let city = selectedCityOrTown as? City {
                countryId = city.idCountry ?? countryId
                cityId = city.id
            } else if let town = selectedCityOrTown as? Town {
                countryId = town.city?.idCountry ?? countryId
                cityId = town.idCity ?? cityId
                townId = town.id
            }

            API.shared.contributionRequest(name: name, category: catApi,
                                           countryId: countryId, cityId: cityId,
                                           townId: townId) { (_) in
                // No action required
            }

            self.showSuccessAlert()
        }
    }
}

extension ContributeViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case tfCategory:
            let selectionMenu = RSSelectionMenu(dataSource: categories) { (cell, item, _) in
                cell.textLabel?.text = item
            }
            selectionMenu.setSelectedItems(items: [tfCategory.text ?? ""]) { [weak self] (_, _, _, selectedItems) in
                self?.tfCategory.text = selectedItems.first ?? ""
            }
            // selectionMenu.show(style: .present, from: self)
            selectionMenu.show(
                style: .popover(sourceView: tfCategory,
                                size: CGSize(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.3)),
                from: self)
            return false

        case tfLocation:
            let selectionMenu = RSSelectionMenu(dataSource: citiesTowns) { (cell, item, _) in
                cell.textLabel?.text = item
            }
            selectionMenu.setSelectedItems(items: [tfLocation.text ?? ""]) { [weak self] (_, _, _, selectedItems) in
                self?.tfLocation.text = selectedItems.first ?? ""
            }
            // selectionMenu.show(style: .present, from: self)
            selectionMenu.show(
                style: .popover(sourceView: tfLocation,
                                size: CGSize(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.5)),
                from: self)
            return false

        default:
            return true
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case tfCategory:
            tfName.becomeFirstResponder()

        case tfName:
            if tfLocation.isUserInteractionEnabled {
                tfLocation.becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }

        case tfLocation:
            send()

        default:
            textField.resignFirstResponder()
        }
        return false
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text),
            textField == tfName,
            text.replacingCharacters(in: textRange, with: string).count > 24 {
            return false
        }

        return true
    }
}
