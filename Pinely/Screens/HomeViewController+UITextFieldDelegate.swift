//
//  HomeViewController+UITextFieldDelegate.swift
//  Pinely
//

import UIKit

extension HomeViewController: UITextFieldDelegate {
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
            if updatedText.containsEmoji {
                return false
            }
            let searchRequest = updatedText.trimmingCharacters(in: .whitespacesAndNewlines)
            if searchRequest.isEmpty {
                filterForTab()
            } else {
                let searchRequestLC = searchRequest.lowercased().folding(options: .diacriticInsensitive, locale: .current)
                buildFilteredPlacesList(searchRequestLC)
                buildFilteredEventsList(searchRequestLC)
                svContent.reloadData()
            }
        }
        return true
    }

    func filterForTab() {
        placesFiltered = places
        eventsFiltered = events
        svContent.reloadData()
    }
}
