//
//  RegistrationViewController.swift
//  Pinely
//

import UIKit
import FirebaseAuth
import SwiftEventBus
import FirebaseAnalytics

class RegistrationViewController: ViewController {
    @IBOutlet weak var tfFirstName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPhone: UITextField!
    @IBOutlet weak var tfDOB: UITextField!
    @IBOutlet weak var tfPassword: UITextField!

    @IBOutlet weak var lTitle: UILabel!
    @IBOutlet weak var lName: UILabel!
    @IBOutlet weak var lLastName: UILabel!
    @IBOutlet weak var lEmail: UILabel!
    @IBOutlet weak var lPhone: UILabel!
    @IBOutlet weak var lAge: UILabel!
    @IBOutlet weak var lPassword: UILabel!
    @IBOutlet weak var lButtonNext: UILabel!

    var selectedDOB: Date?
    let dateFormatter = DateFormatter()

    var presetEmail: String?
    var presetPassword: String?

    let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 216))

    var loadingView: LoadingView?

    fileprivate func localize() {
        guard let translation = AppDelegate.translation else {
            return
        }

        lTitle.text = translation.getString("create_new_account_title") ?? "Crear nueva cuenta"

        lName.text = translation.getString("create_new_account_name") ?? "Nombre"
        lLastName.text = translation.getString("create_new_account_surname") ?? "Apellidos"
        lEmail.text = translation.getString("create_new_account_email") ?? "Email"
        lPhone.text = translation.getString("create_new_account_telephone") ?? "Teléfono"
        lAge.text = translation.getString("create_new_account_age") ?? "Edad"
        lPassword.text = translation.getString("create_new_account_password") ?? "Contraseña"
        lButtonNext.text = translation.getString("create_new_account_button_text") ?? "Siguiente"

        tfFirstName.placeholder = translation.getString("create_new_account_name_placeholder") ?? "Introduce tu nombre"

        tfLastName.placeholder = translation.getString("create_new_account_surname_placeholder") ?? "Introduce tus apellidos"
        tfEmail.placeholder = translation.getString("create_new_account_email_placeholder") ?? "Introduce tu email"
        tfPhone.placeholder = translation.getString("create_new_account_telephone_placeholder") ?? "Introduce tu teléfono"
        tfDOB.placeholder = translation.getString("create_new_account_age_placeholder") ?? "Selecciona una fecha"
        tfPassword.placeholder = translation.getString("create_new_account_password_placeholder") ?? "Introduce tu nombre"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateFormat = "dd/MM/yyyy"

        // let screenWidth = UIScreen.main.bounds.width
        // let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 216))
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "es-ES")
        datePicker.date = Date() // Date(timeIntervalSince1970: 780019200)
        tfDOB.inputView = datePicker

        datePicker.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)

        addDoneButtonOnKeyboard()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let presetEmail = self.presetEmail {
            tfEmail.text = presetEmail
        }
        if let presetPassword = self.presetPassword {
            tfPassword.text = presetPassword
        }
    }

    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Aceptar", style: .done, target: self, action: #selector(self.doneButtonAction))

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        tfDOB.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction() {
        tfDOB.text = dateFormatter.string(from: datePicker.date)
        selectedDOB = datePicker.date
        tfPassword.becomeFirstResponder()
    }

    @objc func handleDatePicker(sender: UIDatePicker) {
        tfDOB.text = dateFormatter.string(from: sender.date)
        selectedDOB = sender.date
    }

    private func userWasCreated(result: AuthDataResult?,
                                firstName: String, lastName: String,
                                email: String, phone: String,
                                dateOfBirth: Date) {
        // User was created, we're in
        let user = result!.user
        let request = user.createProfileChangeRequest()
        request.displayName = "\(firstName) \(lastName)"
        request.commitChanges { (_) in
            // Register in API
            API.shared.registerUser(firstName: firstName,
                                    lastName: lastName, email: email,
                                    mobilePhone: phone, dateOfBirth: dateOfBirth) { (error) in
                self.registrationEnded()
                if let error = error {
                    self.loadingView?.stopAndRemove()
                    self.loadingView = nil
                    self.show(error: error)
                    return
                }

                Analytics.logEvent(AnalyticsEventSignUp, parameters: [
                    AnalyticsParameterMethod: "Email"
                ])

                SwiftEventBus.post("authChanged")
                self.dismiss(animated: true) {
                    self.loadingView?.stopAndRemove()
                    self.loadingView = nil
                }
            }
        }
    }

    fileprivate func doRegistration(
        _ email: String, _ password: String,
        _ firstName: String, _ lastName: String,
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
        present(multiAcceptVC, animated: true, completion: nil)
        SwiftEventBus.onMainThread(self, name: "acceptedAll") { (_) in
            SwiftEventBus.unregister(self)
            self.loadingView = LoadingView.showAndRun(text: "Estamos creando tu\ncuenta, un momento...", viewController: self)

            let userDefaults = UserDefaults.standard
            userDefaults.set(firstName, forKey: StorageKey.registrationFirstName.rawValue)
            userDefaults.set(lastName, forKey: StorageKey.registrationLastName.rawValue)
            userDefaults.set(email, forKey: StorageKey.registrationEmail.rawValue)
            userDefaults.set(phone, forKey: StorageKey.registrationPhone.rawValue)
            userDefaults.set(false, forKey: StorageKey.registrationIsSocial.rawValue)
            userDefaults.set(dateOfBirth.timeIntervalSince1970, forKey: StorageKey.registrationDOB.rawValue)
            userDefaults.set(password, forKey: StorageKey.registrationPassword.rawValue)

            Auth.auth().createUser(withEmail: email, password: password) { [weak self] (result, error) in
                if let error = error?.asAFError,
                   error.responseCode == 17007 {
                    self?.registrationEnded()
                    self?.loadingView?.stopAndRemove()
                    self?.loadingView = nil
                    self?.showError("El email \(email) ya ha sido registrado por otra cuenta, intenta registrar tu cuenta utilizando otro email")
                } else if let error = error {
                    self?.registrationEnded()
                    self?.loadingView?.stopAndRemove()
                    self?.loadingView = nil
                    if error.localizedDescription.contains("email address is already in use") {
                        self?.showError("El email \(email) ya ha sido registrado por otra cuenta, intenta registrar tu cuenta utilizando otro email")
                    } else {
                        self?.show(error: error)
                    }
                } else {
                    self?.userWasCreated(
                        result: result,
                        firstName: firstName, lastName: lastName,
                        email: email, phone: phone,
                        dateOfBirth: dateOfBirth)
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
    }

    private func validateRegistrationFields(
        firstName: String, lastName: String, email: String,
        phone: String, password: String
    ) -> Bool {
        if firstName.isEmpty {
            self.showWarning("Introduce tu nombre")
        } else if firstName.count < 3 {
            self.showWarning("Introduce un nombre válido")
        } else if lastName.isEmpty {
            self.showWarning("Introduce tus apellidos")
        } else if lastName.count < 4 {
            self.showWarning("Introduce tus apellidos correctamente")
        } else if email.isEmpty {
            self.showWarning("Introduce tu email")
        } else if !email.isValidEmail {
            self.showWarning("Introduce un email válido")
        } else if email.lowercased().hasSuffix(".con") {
            let errorText = AppDelegate.translation?.getString("email_domain_not_allowed") ?? ""
            self.showError(errorText)
        } else if phone.isEmpty {
            self.showWarning("Introduce tu teléfono")
        } else if !phone.isPhoneValid {
            self.showWarning("Introduce un teléfono válido")
        } else if self.selectedDOB == nil {
            self.showWarning("Introduce tu fecha de nacimiento")
        } else if (self.selectedDOB?.age ?? 0) < 18 {
            self.showWarning("Para poder registrar tu cuenta tienes que tener 18 años o más")
        } else if password.isEmpty {
            self.showWarning("Introduce tu contraseña")
        } else if password.count < 5 {
            self.showWarning("Introduce una contraseña más segura")
        } else {
            return true
        }
        return false
    }
    @IBAction func createAccount() {
        UIDevice.vibrate()
        view.endEditing(true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let firstName = self.tfFirstName.textPrepared
            let lastName = self.tfLastName.textPrepared
            let email = self.tfEmail.textPrepared
            let phone = self.tfPhone.textPrepared
            let password = self.tfPassword.textPrepared

            if !self.validateRegistrationFields(
                firstName: firstName, lastName: lastName,
                email: email, phone: phone, password: password) {
                return
            }

            if let dateOfBirth = self.selectedDOB {
                self.doRegistration(email, password, firstName, lastName, phone, dateOfBirth)
            }
        }
    }

    deinit {
        SwiftEventBus.unregister(self)
    }
}

extension RegistrationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case tfFirstName:
            tfLastName.becomeFirstResponder()

        case tfLastName:
            tfEmail.becomeFirstResponder()

        case tfEmail:
            tfPhone.becomeFirstResponder()

        case tfPhone:
            tfDOB.becomeFirstResponder()

        case tfDOB:
            tfPassword.becomeFirstResponder()

        case tfPassword:
            textField.resignFirstResponder()
            createAccount()

        default:
            textField.resignFirstResponder()
        }

        return false
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty {
            return true
        }
        if string.containsEmoji {
            return false
        }

        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            if string.count > range.length,
               string.containsEmoji {
                return false
            }
            switch textField {
            case tfLastName, tfEmail:
                if updatedText.count > 45 {
                    return false
                }

            case tfFirstName, tfPhone, tfPassword:
                if updatedText.count > 30 {
                    return false
                }

            default:
                break
            }
        }
        return true
    }
}

extension RegistrationViewController: MultiAcceptDelegate {
    func allAccepted() {
        SwiftEventBus.post("acceptedAll")
    }
}
