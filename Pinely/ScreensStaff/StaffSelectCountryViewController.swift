//
//  StaffSelectCountryViewController.swift
//  Pinely
//

import UIKit

class StaffSelectCountryViewController: ViewController {
    @IBOutlet weak var tvCountres: UITableView!

    var countries: [StaffCountry] = []
    var countriesFiltered: [StaffCountry] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
    }

    private func loadData() {
        if countries.isEmpty {
            if StaffCountry.countryNames.isEmpty {
                StaffCountry.loadCountryNames(lang: "es")
            }

            API.shared.checkCountriesColaboration { (countries, error) in
                if let error = error {
                    self.show(error: error)
                }

                self.countries = countries
                self.filter(request: self.tfSearch?.text ?? "")
            }
        } else {
            self.filter(request: self.tfSearch?.text ?? "")
        }
    }

    private func filter(request: String) {
        if request.isEmpty {
            countriesFiltered = countries
        } else {
            let requestPrepared = request.lowercased().folding(options: .diacriticInsensitive, locale: .current)
            countriesFiltered = countries.filter {
                $0.getName().lowercased().folding(options: .diacriticInsensitive, locale: .current).contains(requestPrepared)
            }
        }
        self.tvCountres.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let staffSelectPartnerTypeVC = segue.destination as? StaffSelectPartnerTypeViewController {
            staffSelectPartnerTypeVC.country = (sender as? StaffCountry)?.code
        }
    }
}

extension StaffSelectCountryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        countriesFiltered.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellCountry", for: indexPath) as? CellCountry
        cell?.prepare(country: countriesFiltered[indexPath.row], isLast: indexPath.row == countriesFiltered.count - 1)
        return cell ?? UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        self.performSegue(withIdentifier: "StaffSelectPartnerType", sender: countries[indexPath.row])
    }
}

extension StaffSelectCountryViewController: UITextFieldDelegate {
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
