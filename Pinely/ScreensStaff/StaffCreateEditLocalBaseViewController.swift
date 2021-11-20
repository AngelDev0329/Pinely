//
//  StaffCreateEditLocalBaseViewController.swift
//  Pinely
//

import UIKit

class StaffCreateEditLocalBaseViewController: ViewController {
    @IBOutlet weak var tfType: UITextField!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfSlogan: UITextField!
    @IBOutlet weak var tvDescription: UITextView!

    @IBOutlet weak var lblDescriptionHint: UILabel!

    @IBOutlet weak var vInfoPanel: UIView!
    @IBOutlet weak var vInfoType: UIView!
    @IBOutlet weak var vInfoDescription: UIView!

    var typePicker: UIPickerView!
    var typeOptions = ["Discoteca", "Bar o Pub"]

    override func viewDidLoad() {
        super.viewDidLoad()

        typePicker = UIPickerView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 216))
        typePicker.delegate = self
        typePicker.dataSource = self
        tfType.inputView = typePicker

        addNextButtonOnKeyboard(tfType, tag: 1)
        addNextButtonOnKeyboard(tfName, tag: 2)
        addNextButtonOnKeyboard(tfSlogan, tag: 3)
        addNextButtonOnKeyboard(tvDescription, tag: 4)
    }

    func addNextButtonOnKeyboard(_ textField: UITextField, tag: Int) {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Siguente", style: .done, target: self, action: #selector(self.doneButtonAction(_:)))
        done.tag = tag

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        textField.inputAccessoryView = doneToolbar
    }

    func addNextButtonOnKeyboard(_ textView: UITextView, tag: Int) {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Siguente", style: .done, target: self, action: #selector(self.doneButtonAction(_:)))
        done.tag = tag

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        textView.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction(_ sender: UIBarButtonItem) {
        switch sender.tag {
        case 1: tfName.becomeFirstResponder()
        case 2: tfSlogan.becomeFirstResponder()
        case 3: tvDescription.becomeFirstResponder()
        case 4:
            tvDescription.resignFirstResponder()
            lastFieldDone()
        default: view.endEditing(true)
        }
    }

    func lastFieldDone() {
        // Must be overriden
    }

    @IBAction func showTypeInfo() {
        vInfoType.isHidden = false
        vInfoDescription.isHidden = true
        appearPanel()
    }

    @IBAction func showDescriptionInfo() {
        vInfoType.isHidden = true
        vInfoDescription.isHidden = false
        appearPanel()
    }

    private func appearPanel() {
        vInfoPanel.alpha = 0.0
        vInfoPanel.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.vInfoPanel.alpha = 1.0
        }
    }

    @IBAction func hidePanel() {
        UIView.animate(withDuration: 0.3) {
            self.vInfoPanel.alpha = 0.0
        } completion: { (_) in
            self.vInfoPanel.isHidden = true
        }
    }
}

extension StaffCreateEditLocalBaseViewController: UITextFieldDelegate, UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case tfType:
            tfName.becomeFirstResponder()

        case tfName:
            tfSlogan.becomeFirstResponder()

        case tfSlogan:
            tvDescription.becomeFirstResponder()

        default:
            textField.resignFirstResponder()
        }
        return false
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == tfType,
           (tfType.text ?? "").isEmpty {
            tfType.text = typeOptions[0]
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        lblDescriptionHint.isHidden = true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        lblDescriptionHint.isHidden = !(textView.text ?? "").isEmpty
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            if textField == tfName,
               updatedText.count > 45 {
                return false
            }
        }
        return true
    }
}

extension StaffCreateEditLocalBaseViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        typeOptions.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        typeOptions[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        tfType.text = typeOptions[row]
    }
}
