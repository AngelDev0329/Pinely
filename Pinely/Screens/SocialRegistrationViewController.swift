//
//  SocialRegistrationViewController.swift
//  Pinely
//

import UIKit
import FirebaseAuth
import SwiftEventBus
import FirebaseAnalytics

class SocialRegistrationViewController: ViewController {
    @IBOutlet weak var tfFirstName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPhone: UITextField!
    @IBOutlet weak var tfDOB: UITextField!

    var userConfirmed = false
    var authProvider: String = ""

    var selectedDOB: Date?
    let dateFormatter = DateFormatter()

    let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 216))

    override func viewDidLoad() {
        super.viewDidLoad()

        authProvider = UserDefaults.standard.string(forKey: StorageKey.registrationUnfinishedSocialType.rawValue) ?? "Unknown Social"

        tfEmail.setEmailFromFirebase()
        tfFirstName.setFirstNameFromFirebase()
        tfLastName.setLastNameFromFirebase()

        dateFormatter.dateFormat = "dd/MM/yyyy"

        // let screenWidth = UIScreen.main.bounds.width
        // let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 216))
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

    override func viewWillDisappear(_ animated: Bool) {
        if !userConfirmed {
            UserDefaults.standard.removeObject(forKey: StorageKey.registrationUnfinishedSocial.rawValue)
            UserDefaults.standard.removeObject(forKey: StorageKey.registrationUnfinishedSocialType.rawValue)
            _ = try? Auth.auth().signOut()
            SwiftEventBus.post("authChanged")
        }

        super.viewWillDisappear(animated)
    }

    func addDoneButtonOnKeyboard() {
        let toolbarRect = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50)
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

        let authStoryboard = self.storyboard ?? UIStoryboard(name: "Auth", bundle: nil)
        guard let multiAcceptVC =
                authStoryboard.instantiateViewController(withIdentifier: "MultiAccept") as? MultiAcceptController
        else {
            return
        }
        multiAcceptVC.titles = titles
        multiAcceptVC.urls = urls
        multiAcceptVC.acceptDelegate = self
        multiAcceptVC.modalPresentationStyle = .fullScreen
        userConfirmed = true
        present(multiAcceptVC, animated: true) {
            self.userConfirmed = false
        }
        SwiftEventBus.onMainThread(self, name: "acceptedAll") { (_) in
            SwiftEventBus.unregister(self)

            let userDefaults = UserDefaults.standard
            userDefaults.set(firstName, forKey: StorageKey.registrationFirstName.rawValue)
            userDefaults.set(lastName, forKey: StorageKey.registrationLastName.rawValue)
            userDefaults.set(email, forKey: StorageKey.registrationEmail.rawValue)
            userDefaults.set(phone, forKey: StorageKey.registrationPhone.rawValue)
            userDefaults.set(true, forKey: StorageKey.registrationIsSocial.rawValue)
            userDefaults.set(dateOfBirth.timeIntervalSince1970, forKey: StorageKey.registrationDOB.rawValue)

            let loadingView = LoadingView.showAndRun(
                text: "Estamos creando tu\ncuenta, un momento...",
                viewController: self)

            // Register in API
            UserDefaults.standard.removeObject(forKey: StorageKey.registrationUnfinishedSocial.rawValue)
            UserDefaults.standard.removeObject(forKey: StorageKey.registrationUnfinishedSocialType.rawValue)
            API.shared.registerUser(firstName: firstName,
                                    lastName: lastName, email: email,
                                    mobilePhone: phone, dateOfBirth: dateOfBirth) { (error) in
                self.registrationEnded()
                if let error = error {
                    loadingView?.stopAndRemove()
                    self.show(error: error)
                    return
                }

//                API.shared.sendWelcomeEmail(name: "\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines), email: email) { (_) in
//                    
//                }

                Analytics.logEvent(AnalyticsEventSignUp, parameters: [
                    AnalyticsParameterMethod: self.authProvider
                ])

                self.userConfirmed = true
                SwiftEventBus.post("authChanged")
                self.dismiss(animated: true) {
                    loadingView?.stopAndRemove()
                }
            }
        }
    }

    private func registrationEnded() {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: StorageKey.registrationFirstName.rawValue)
        userDefaults.removeObject(forKey: StorageKey.registrationLastName.rawValue)
        userDefaults.removeObject(forKey: StorageKey.registrationEmail.rawValue)
        userDefaults.removeObject(forKey: StorageKey.registrationPhone.rawValue)
        userDefaults.removeObject(forKey: StorageKey.registrationIsSocial.rawValue)
        userDefaults.removeObject(forKey: StorageKey.registrationDOB.rawValue)
        userDefaults.removeObject(forKey: StorageKey.registrationPassword.rawValue)
        userDefaults.removeObject(forKey: StorageKey.registrationUnfinishedSocial.rawValue)
        userDefaults.removeObject(forKey: StorageKey.registrationUnfinishedSocialType.rawValue)
    }

    @IBAction func createAccount() {
        UIDevice.vibrate()
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

            if email.isEmpty {
                self.showWarning("Introduce un email válido")
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

extension SocialRegistrationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case tfFirstName:
            tfLastName.becomeFirstResponder()

        case tfLastName:
//            tfEmail.becomeFirstResponder()
//
//        case tfEmail:
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

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            if string.count > range.length,
               string.containsEmoji {
                return false
            }
            switch textField {
            case tfFirstName, tfPhone:
                if updatedText.count > 30 {
                    return false
                }

            case tfLastName:
                if updatedText.count > 45 {
                    return false
                }

            default:
                break
            }
        }
        return true
    }
}

extension SocialRegistrationViewController: MultiAcceptDelegate {
    func allAccepted() {
        SwiftEventBus.post("acceptedAll")
    }
}
