//
//  StaffCreateNewEmployeeViewController.swift
//  Pinely
//

import UIKit

class StaffCreateNewEmployeeViewController: ViewController {
    @IBOutlet weak var tfType: UITextField!
    @IBOutlet weak var tfEmail: UITextField!

    var rangePicker: UIPickerView!
    let rangeOptions = ["Lector", "Revisor", "Administrador"]
    let rangeAPI = ["reader", "revisor", "staff"]

    override func viewDidLoad() {
        super.viewDidLoad()

        rangePicker = UIPickerView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 216))
        rangePicker.delegate = self
        rangePicker.dataSource = self
        tfType.inputView = rangePicker

        addDoneButtonOnKeyboard(textField: tfType, buttonTitle: "Siguiente")
        addDoneButtonOnKeyboard(textField: tfEmail, buttonTitle: "Aceptar")
    }

    func addDoneButtonOnKeyboard(textField: UITextField, buttonTitle: String) {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: buttonTitle, style: .done, target: self, action: #selector(self.doneButtonAction))

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        textField.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction() {
        if tfType.isFirstResponder {
            tfEmail.becomeFirstResponder()
        } else if tfEmail.isFirstResponder {
            tfEmail.resignFirstResponder()
        } else {
            view.endEditing(true)
        }
    }

    @IBAction func createNewEmployee() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.doCreate()
        }
    }

    private func doCreate() {
        self.goBack()
    }
}

extension StaffCreateNewEmployeeViewController: UITextFieldDelegate, UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case tfType:
            tfEmail.becomeFirstResponder()

        case tfEmail:
            textField.resignFirstResponder()
            self.doCreate()

        default:
            textField.resignFirstResponder()
        }
        return false
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == tfType,
           (tfType.text ?? "").isEmpty {
            tfType.text = rangeOptions[0]
        }
    }
}

extension StaffCreateNewEmployeeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        rangeOptions.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        rangeOptions[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        tfType.text = rangeOptions[row]
    }
}
