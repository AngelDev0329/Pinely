//
//  FinishRegistrationViewController.swift
//  Pinely
//

import UIKit
import SwiftEventBus
import FirebaseAuth

class FinishRegistrationViewController: ViewController {
    @IBOutlet weak var tfFirstName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPhone: UITextField!
    @IBOutlet weak var tfDOB: UITextField!

    var selectedDOB: Date?
    let dateFormatter = DateFormatter()

    let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 216))

    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateFormat = "dd/MM/yyyy"

        tfEmail.setEmailFromFirebase()
        tfFirstName.setFirstNameFromFirebase()
        tfLastName.setLastNameFromFirebase()

        let loading = BlurryLoadingView.showAndStart()
        API.shared.loadUserInfo(force: true) { (profile, _) in
            loading.stopAndHide()
            if let profile = profile {
                self.tfFirstName.text = profile.name ?? ""
                self.tfLastName.text = profile.lastName ?? ""
                let dfFrom = DateFormatter()
                dfFrom.dateFormat = "yyyy-MM-dd"
                if let dobStr = profile.dateOfBirth,
                   let dateOfBirth = dfFrom.date(from: dobStr) {
                    self.tfDOB.text = self.dateFormatter.string(from: dateOfBirth)
                }
                self.tfPhone.text = profile.mobilePhone ?? ""
            }
        }

        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "es-ES")
        datePicker.date = Date(timeIntervalSince1970: 780019200)
        tfDOB.inputView = datePicker

        datePicker.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)

        addDoneButtonOnKeyboard()
    }

    func addDoneButtonOnKeyboard() {
        let toolbarRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50)
        let doneToolbar = UIToolbar(frame: toolbarRect)
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(
            title: "Aceptar", style: .done,
            target: self, action: #selector(self.doneButtonAction))

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        tfDOB.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction() {
        tfDOB.text = dateFormatter.string(from: datePicker.date)
        selectedDOB = datePicker.date
        view.endEditing(true)
    }

    @objc func handleDatePicker(sender: UIDatePicker) {
        tfDOB.text = dateFormatter.string(from: sender.date)
        selectedDOB = sender.date
    }

    fileprivate func doRegistration(_ user: FirebaseAuth.User, _ firstName: String,
                                    _ lastName: String, _ email: String,
                                    _ phone: String, _ dateOfBirth: Date) {
        SwiftEventBus.unregister(self)
        let titles = ["Términos y Condiciones", "Política de privacidad"]
        let urls = [
            PageLink.termsAndConditions.getUrl()!,
            PageLink.privacyPolicy.getUrl()!
        ]

        let authStoryboard = UIStoryboard(name: "Auth", bundle: nil)
        guard let multiAcceptVC =
                authStoryboard.instantiateViewController(withIdentifier: "MultiAccept")
                as? MultiAcceptController
        else {
            return
        }
        multiAcceptVC.titles = titles
        multiAcceptVC.urls = urls
        multiAcceptVC.acceptDelegate = self
        multiAcceptVC.modalPresentationStyle = .fullScreen
        present(multiAcceptVC, animated: true, completion: nil)

        SwiftEventBus.onMainThread(self, name: "acceptedAll") { (_) in
            SwiftEventBus.unregister(self)

            let loading = BlurryLoadingView.showAndStart()

            // Register in API
            API.shared.finishRegistration(uid: user.uid, firstName: firstName,
                                          lastName: lastName, email: email,
                                          mobilePhone: phone, dateOfBirth: dateOfBirth) { (error) in
                if let error = error {
                    loading.stopAndHide()
                    self.show(error: error)
                    return
                }

                loading.stopAndHide()
                SwiftEventBus.post("authChanged")
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    @IBAction func createAccount() {
        view.endEditing(true)

        guard let user = Auth.auth().currentUser else {
            self.showError("User is not logged in, can't change information")
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let firstName = self.tfFirstName.textPrepared
            let lastName = self.tfLastName.textPrepared
            let email = self.tfEmail.textPrepared
            let phone = self.tfPhone.textPrepared

            if firstName.isEmpty {
                self.showWarning("Introduce un nombre válido")
                return
            }

            if lastName.isEmpty {
                self.showWarning("Introduce unos apellidos válidos")
                return
            }

            if phone.isEmpty {
                self.showWarning("Introduce un teléfono válido")
                return
            }

            guard let dateOfBirth = self.selectedDOB else {
                self.showWarning("Selecciona tu fecha de nacimiento")
                return
            }

            self.doRegistration(user, firstName, lastName, email, phone, dateOfBirth)
        }
    }

    deinit {
        SwiftEventBus.unregister(self)
    }
}

extension FinishRegistrationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case tfFirstName:
            tfLastName.becomeFirstResponder()

        case tfLastName:
            tfPhone.becomeFirstResponder()

        case tfPhone:
            tfDOB.becomeFirstResponder()

        case tfDOB:
            createAccount()

        default:
            textField.resignFirstResponder()
        }

        return false
    }

    fileprivate func validateInput(_ textField: UITextField, _ updatedText: String) -> Bool {
        switch textField {
        case tfFirstName, tfPhone:
            if updatedText.count > 30 {
                return false
            }

        case tfLastName, tfEmail:
            if updatedText.count > 45 {
                return false
            }

        default:
            break
        }
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            if string.count > range.length,
               string.containsEmoji {
                return false
            }
            return validateInput(textField, updatedText)
        }
        return true
    }
}

extension FinishRegistrationViewController: MultiAcceptDelegate {
    func allAccepted() {
        SwiftEventBus.post("acceptedAll")
    }
}
