//
//  StaffEditEmployeeViewController.swift
//  Pinely
//

import UIKit

class StaffEditEmployeeViewController: ViewController {
    @IBOutlet weak var tfType: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfAssignments: UITextField!

    var rangePicker: UIPickerView!
    let rangeOptions = ["Lector", "Revisor", "Administrador"]
    let rangeAPI = ["reader", "revisor", "sub-staff"]
    let altRangeAPI = [nil, nil, "staff"]

    var employee: Employee!

    override func viewDidLoad() {
        super.viewDidLoad()

        rangePicker = UIPickerView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 216))
        rangePicker.delegate = self
        rangePicker.dataSource = self
        tfType.inputView = rangePicker

        if let index = rangeAPI.firstIndex(of: employee.range ?? "") {
            tfType.text = rangeOptions[index]
        } else if let index = altRangeAPI.firstIndex(of: employee.range ?? "") {
            tfType.text = rangeOptions[index]
        } else {
            tfType.text = ""
        }

        tfEmail.text = employee.email
        tfAssignments.text = "2 salas asignadas"
    }

    @IBAction func eliminarEmployee() {

    }

    @IBAction func editAssignments() {

    }

    @IBAction func applyChanges() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.doSave()
        }
    }

    private func doSave() {
        self.goBack()
    }
}

extension StaffEditEmployeeViewController: UITextFieldDelegate, UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case tfType:
            tfEmail.becomeFirstResponder()

        case tfEmail:
            textField.resignFirstResponder()
            self.doSave()

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

extension StaffEditEmployeeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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
