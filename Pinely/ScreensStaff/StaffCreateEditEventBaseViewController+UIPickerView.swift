//
//  StaffCreateEventViewController+UIPickerView.swift
//  Pinely
//

import Foundation

extension StaffCreateEditEventBaseViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case agePicker:
            return ageOptions.count

        case clothingPicker:
            return clothingOptions.count

        default:
            return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case agePicker:
            return AgeOptions.getTextEditFor(ageOptions[row])

        case clothingPicker:
            return clothingOptions[row]

        default:
            return ""
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case agePicker:
            tfAge.text = AgeOptions.getTextEditFor(ageOptions[row])

        case clothingPicker:
            tfClothing.text = clothingOptions[row]

        default:
            break
        }
    }
}
