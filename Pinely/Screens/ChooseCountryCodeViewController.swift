//
//  ChooseCountryCodeViewController.swift
//  Pinely
//

import UIKit
import CountryPickerView

class ChooseCountryCodeViewController: ViewController {
    @IBOutlet weak var tvCountries: UITableView!

    var countries: [[String: Any]] = []
    var countriesFiltered: [[String: Any]] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        countries = CountrySelectView.shared.searchCountrys
        for i in 0..<countries.count {
            var country = countries[i]
            if country["countryImage"] == nil,
               let locale = country.getString("locale") {
                country["countryImage"] = UIImage(named: "CountryPicker.bundle/\(locale)")
                countries[i] = country
            }
        }
        countriesFiltered = countries

        tvCountries.reloadData()
    }
}

extension ChooseCountryCodeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        countriesFiltered.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCode", for: indexPath) as? CellCountryCode
        cell?.backgroundColor = .clear
        cell?.prepare(country: countriesFiltered[indexPath.row], isLast: indexPath.row >= countriesFiltered.count - 1)
        return cell ?? UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let navigationController = self.navigationController {
            let country = countriesFiltered[indexPath.row]
            (navigationController.viewControllers.first(
                where: { $0 is MobileVerificationViewController }) as? MobileVerificationViewController)?
                .countrySelected(countryDic: country)
        }
        self.goBack()
    }
}

extension ChooseCountryCodeViewController: UITextFieldDelegate {
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
            let searchRequest = updatedText.trimmingCharacters(in: .whitespacesAndNewlines)
            if searchRequest.isEmpty {
                countriesFiltered = countries
            } else {
                let searchRequestLC = searchRequest.lowercased().folding(options: .diacriticInsensitive, locale: .current)
                countriesFiltered = countries.filter { (country) -> Bool in
                    (country.getString("es") ?? "").lowercased()
                        .folding(options: .diacriticInsensitive, locale: .current)
                        .contains(searchRequestLC) || (country.getString("code") ?? "").contains(searchRequestLC)
                }
            }
            tvCountries.reloadData()
        }
        return true
    }
}
