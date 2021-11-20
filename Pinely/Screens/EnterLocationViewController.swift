//
//  EnterLocationViewController.swift
//  Pinely
//

import UIKit
// import MapKit

class EnterLocationViewController: ViewController {
    @IBOutlet weak var tvList: UITableView!
    @IBOutlet weak var lblChangeLocation: UILabel!

    var searchResults: [String] = []

    var searchStrings: [String] = []
    var cityTownMatch: [String: CityOrTown] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        City.shared.forEach { city in
            let cName = city.getFullName()
            self.searchStrings.append(cName)
            self.cityTownMatch[cName] = city

            let towns = Town.shared.filter { $0.idCity == city.id }
            towns.forEach { town in
                let tName = town.getFullName()
                self.searchStrings.append(tName)
                self.cityTownMatch[tName] = town
            }
        }

        if let translation = AppDelegate.translation {
            lblChangeLocation.text = translation.getString("change_my_location_title") ?? lblChangeLocation.text

        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        tfSearch?.becomeFirstResponder()
    }

    @IBAction func focusOnSearch() {
        tfSearch?.becomeFirstResponder()
    }

    func search(request: String) {
        let requestLc = request.lowercased().folding(options: .diacriticInsensitive, locale: .current)
        searchResults = searchStrings.filter {
            $0.lowercased().folding(options: .diacriticInsensitive, locale: .current).contains(requestLc)
        }
        tvList.reloadData()
    }
}

extension EnterLocationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityCountry", for: indexPath) as? CellCityCountry
        if indexPath.row < searchResults.count {
            cell?.prepare(location: searchResults[indexPath.row], isLast: indexPath.row == searchResults.count - 1)
        }
        return cell ?? UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.row >= searchResults.count {
            return
        }

        //        HUD.show(.progress)
        let item = searchResults[indexPath.row]

        guard let cityOrTown = cityTownMatch[item],
              let latitude = cityOrTown.latitude,
              let longitude = cityOrTown.longitude
        else {
            return
        }

        UIDevice.vibrate()

        Town.chooseNearestTo(latitude: latitude, longitude: longitude)
        self.dismiss(animated: true, completion: nil)
    }
}

extension EnterLocationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)

            if updatedText.containsEmoji {
                return false
            }

            search(request: updatedText)
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
