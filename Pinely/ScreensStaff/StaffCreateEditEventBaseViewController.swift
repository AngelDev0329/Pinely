//
//  StaffCreateEditEventBaseViewController.swift
//  Pinely
//

import UIKit

class StaffCreateEditEventBaseViewController: ViewController {
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfStart: UITextField!
    @IBOutlet weak var tfEnd: UITextField!
    @IBOutlet weak var tfAge: UITextField!
    @IBOutlet weak var tfClothing: UITextField!
    @IBOutlet weak var tfSlogan: UITextField!
    @IBOutlet weak var tvDescription: UITextView!
    @IBOutlet weak var lblDescriptionHint: UILabel!

    @IBOutlet weak var vButtonContainer: UIView!

    let fromPicker = UIDatePicker()
    let toPicker = UIDatePicker()
    let agePicker = UIPickerView()
    let clothingPicker = UIPickerView()

    var startDate: Date?
    var endDate: Date?

    var ageOptions: [Int] {
        AgeOptions.options
    }
    var clothingOptions: [String] {
        ClothesOptions.options
    }

    let dateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"

        fromPicker.minuteInterval = 5
        toPicker.minuteInterval = 5

        if #available(iOS 13.4, *) {
            fromPicker.preferredDatePickerStyle = .wheels
            toPicker.preferredDatePickerStyle = .wheels
        }

        tfStart.inputView = fromPicker
        tfEnd.inputView = toPicker

        fromPicker.addTarget(self, action: #selector(fromDateChanged), for: .valueChanged)
        toPicker.addTarget(self, action: #selector(toDateChanged), for: .valueChanged)

        tfAge.inputView = agePicker
        tfClothing.inputView = clothingPicker

        agePicker.delegate = self
        agePicker.dataSource = self
        clothingPicker.delegate = self
        clothingPicker.dataSource = self

        addDoneButtonOnKeyboard(textField: tfName, title: "Siguiente", action: #selector(self.doneButtonActionGeneric))
        addDoneButtonOnKeyboard(textField: tfStart, title: "Siguiente", action: #selector(self.doneButtonActionGeneric))
        addDoneButtonOnKeyboard(textField: tfEnd, title: "Siguiente", action: #selector(self.doneButtonActionGeneric))
        addDoneButtonOnKeyboard(textField: tfAge, title: "Siguiente", action: #selector(self.doneButtonActionGeneric))
        addDoneButtonOnKeyboard(textField: tfClothing, title: "Siguiente", action: #selector(self.doneButtonActionGeneric))
        addDoneButtonOnKeyboard(textField: tfSlogan, title: "Siguiente", action: #selector(self.doneButtonActionGeneric))
        addDoneButtonOnKeyboard(textView: tvDescription, title: "Aceptar", action: #selector(self.doneButtonActionGeneric))
    }

    @objc func fromDateChanged() {
        let calendar = Calendar.current
        var date = fromPicker.date
        if calendar.component(.minute, from: date) % 5 != 0 {
            date = calendar.date(byAdding: .minute, value: -(calendar.component(.minute, from: date) % 5), to: date)!
        }

        tfStart.text = dateFormatter.string(from: date)
        startDate = date
    }

    @objc func toDateChanged() {
        let calendar = Calendar.current
        var date = toPicker.date
        if calendar.component(.minute, from: date) % 5 != 0 {
            date = calendar.date(byAdding: .minute, value: -(calendar.component(.minute, from: date) % 5), to: date)!
        }

        tfEnd.text = dateFormatter.string(from: date)
        endDate = date
    }

    func showHideButton() {
        let name = tfName.text ?? ""
        let age = tfAge.text ?? ""
        let clothing = tfClothing.text ?? ""
        let slogan = tfSlogan.text ?? ""
        let descr = tvDescription.text ?? ""

        vButtonContainer.isHidden = name.isEmpty || age.isEmpty || clothing.isEmpty ||
        slogan.isEmpty || descr.isEmpty || startDate == nil || endDate == nil
    }

    func addDoneButtonOnKeyboard(textField: UITextField, title: String, action: Selector?) {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: title, style: .done, target: self, action: action)

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        textField.inputAccessoryView = doneToolbar
    }

    func addDoneButtonOnKeyboard(textView: UITextView, title: String, action: Selector?) {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: title, style: .done, target: self, action: action)

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        textView.inputAccessoryView = doneToolbar
    }

    private func startFieldDone() {
        if (tfStart.text ?? "").isEmpty {
            let calendar = Calendar.current
            var date = fromPicker.date
            if calendar.component(.minute, from: date) % 5 != 0 {
                date = calendar.date(byAdding: .minute, value: -(calendar.component(.minute, from: date) % 5), to: date)!
            }

            tfStart.text = dateFormatter.string(from: date)
            startDate = date
        }
        tfEnd.becomeFirstResponder()
    }

    private func endFieldDone() {
        if (tfEnd.text ?? "").isEmpty {
            let calendar = Calendar.current
            var date = toPicker.date
            if calendar.component(.minute, from: date) % 5 != 0 {
                date = calendar.date(byAdding: .minute, value: -(calendar.component(.minute, from: date) % 5), to: date)!
            }

            tfEnd.text = dateFormatter.string(from: date)
            endDate = date
        }
        tfAge.becomeFirstResponder()
    }

    @objc func doneButtonActionGeneric() {
        if tfName.isFirstResponder {
            tfStart.becomeFirstResponder()
        } else if tfStart.isFirstResponder {
            startFieldDone()
        } else if tfEnd.isFirstResponder {
            endFieldDone()
        } else if tfAge.isFirstResponder {
            if (tfAge.text ?? "").isEmpty {
                tfAge.text = AgeOptions.getTextEditFor(ageOptions[agePicker.selectedRow(inComponent: 0)])
            }
            tfClothing.becomeFirstResponder()
        } else if tfClothing.isFirstResponder {
            if (tfClothing.text ?? "").isEmpty {
                tfClothing.text = clothingOptions[clothingPicker.selectedRow(inComponent: 0)]
            }
            tfSlogan.becomeFirstResponder()
        } else if tfSlogan.isFirstResponder {
            tvDescription.becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
    }

    @IBAction func showDescriptionTip() {

    }

    @IBAction func createAndContinue() {
        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let name = self.tfName.text ?? ""
            let slogan = self.tfSlogan.text ?? ""
            let descr = self.tvDescription.text ?? ""

            if name.count < 4 {
                self.showError("El nombre del evento es demasiado corto")
                return
            } else if name.count > 100 {
                self.showError("El nombre del evento es demasiado largo")
                return
            }

            if slogan.count < 4 {
                self.showError("El eslogan de este evento es demasiado corto")
                return
            } else if slogan.count > 100 {
                self.showError("El eslogan de este evento es demasiado largo")
                return
            }

            if descr.count < 4 {
                self.showError("La descripción de este evento es demasiado corto")
                return
            } else if descr.count > 100 {
                self.showError("La descripción de este evento es demasiado largo")
                return
            }

            if let startDate = self.startDate,
               let endDate = self.endDate,
               startDate.timeIntervalSince(endDate) > 0 {
                self.showError("La fecha de finalización del evento no puede ser anterior a la fecha de inicio")
                return
            }

            self.apply(name: name, slogan: slogan, descr: descr)
        }
    }

    func apply(name: String, slogan: String, descr: String) {
        // Must be overriden
        fatalError("Method StaffCreateEditEventBaseViewController.apply can't be used directly")
    }
}
