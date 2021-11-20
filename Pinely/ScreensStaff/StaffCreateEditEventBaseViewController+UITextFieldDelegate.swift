//
//  StaffCreateEditEventBaseViewController+UITextFieldDelegate.swift
//  Pinely
//

import UIKit

extension StaffCreateEditEventBaseViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case tfName: tfStart.becomeFirstResponder()
        case tfStart: tfEnd.becomeFirstResponder()
        case tfEnd: tfAge.becomeFirstResponder()
        case tfAge: tfClothing.becomeFirstResponder()
        case tfClothing: tfSlogan.becomeFirstResponder()
        case tfSlogan: tvDescription.becomeFirstResponder()
        default: textField.resignFirstResponder()
        }

        return false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        showHideButton()
    }
}
