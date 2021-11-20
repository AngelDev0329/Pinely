//
//  StaffCreateNewEntryViewController.swift
//  Pinely
//

import UIKit

class StaffCreateNewEntryViewController: ViewController {
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfLimit: UITextField!
    @IBOutlet weak var tfPrice: UITextField!
    @IBOutlet weak var tfIVA: UITextField!
    @IBOutlet weak var tfNumber: UITextField!

    @IBOutlet weak var vCreate: UIView!

    let datePicker = UIDatePicker()
    var selectedDateTime: Date?

    override func viewDidLoad() {
        super.viewDidLoad()

        datePicker.addTarget(self, action: #selector(dateTimeChanged), for: .valueChanged)
        datePicker.datePickerMode = .dateAndTime
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        tfLimit.inputView = datePicker

        showHideCreateButton()
    }

    @objc func dateTimeChanged() {
        self.showDateTime(datePicker.date)
    }

    @IBAction func createEntry() {
        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.goBack()
        }
    }

    private func showDateTime(_ dateTime: Date) {
        self.selectedDateTime = dateTime
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy' a las 'HH:mm"
        self.tfLimit.text = dateFormatter.string(from: dateTime)
    }

    private func showHideCreateButton() {
        let name = tfName.text ?? ""
        let price = Double(tfPrice.text ?? "")
        let ivaNumber = Int(tfIVA.text ?? "")
        let number = Int(tfNumber.text ?? "")

        vCreate.isHidden = name.isEmpty || price == nil || ivaNumber == nil || number == nil
    }
}

extension StaffCreateNewEntryViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == tfLimit,
           selectedDateTime == nil {
            self.showDateTime(Date())
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.showHideCreateButton()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case tfName: tfLimit.becomeFirstResponder()
        case tfLimit: tfPrice.becomeFirstResponder()
        case tfPrice: tfIVA.becomeFirstResponder()
        case tfIVA: tfNumber.becomeFirstResponder()
        default: textField.resignFirstResponder()
        }
        return false
    }
}
