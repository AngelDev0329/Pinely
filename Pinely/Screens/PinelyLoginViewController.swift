//
//  PinelyLoginViewController.swift
//  Pinely
//

import UIKit
import FirebaseAuth
import SwiftEventBus
import FirebaseAnalytics

class PinelyLoginViewController: ViewController {
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var lcY: NSLayoutConstraint! // swiftlint:disable:this identifier_name

    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblPassword: UILabel!
    @IBOutlet weak var lblLogin: UILabel!
    @IBOutlet weak var btnForgot: UIButton!
    @IBOutlet weak var btnRegister: UIButton!

    let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
    override func viewDidLoad() {
        if let translation = AppDelegate.translation {
            lblEmail.text = translation.getString("email_login") ?? lblEmail.text
            lblPassword.text = translation.getString("password_login") ?? lblPassword.text
            lblLogin.text = translation.getString("login_button_text") ?? lblLogin.text

            btnForgot.titleLabel?.text = translation.getString("forget_password_login") ?? btnForgot.titleLabel?.text

            btnRegister.setTitleFromTranslation("register_new_account_login", translation)
            btnForgot.setTitleFromTranslation("forget_password_login", translation)

            tfEmail.placeholder = translation.getString("placeholder_email_login") ?? tfEmail.placeholder
            tfPassword.placeholder = translation.getString("placeholder_password_login") ?? tfPassword.placeholder

        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        view.endEditing(true)

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
       let keyboardHeight = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 320
       self.lcY.constant = -keyboardHeight / 4
       UIView.animate(withDuration: 0.3) {
           self.view.layoutIfNeeded()
       }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.lcY.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    @IBAction func startSession() {
        UIDevice.vibrate()
        view.endEditing(true)
        notificationFeedbackGenerator.prepare()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            guard let email = self.tfEmail.text,
                !email.isEmpty
            else {
                self.showWarning("warning.enteremail".localized)
                return
            }

            guard let password = self.tfPassword.text,
                !password.isEmpty
            else {
                self.showWarning("warning.enterpassword".localized)
                return
            }

            let loading = BlurryLoadingView.showAndStart()
            Auth.auth().signIn(withEmail: email, password: password) { (_, error) in
                if let error = error {
                    loading.stopAndHide()
                    if error.localizedDescription.contains("many failed login attempts") {
                        self.showError("error.blockedAfterFail".localized)
                    } else if error.localizedDescription.contains("There is no user record corresponding to this identifier") {
                        self.performSegue(withIdentifier: "registration", sender: (email, password))
                    } else {
                        self.show(error: error)
                    }
                    return
                }

                // Logged in with existing user, we're in
                self.notificationFeedbackGenerator.notificationOccurred(.success)
                API.shared.getUserToken { (_, _) in
                    self.loginEndedWithSuccess(method: "Email", loadingView: loading)
                }
            }
        }
    }

    @IBAction func forgotPassword() {
        view.endEditing(true)

        guard let email = self.tfEmail.text,
            !email.isEmpty
        else {

            if let translation = AppDelegate.translation {
                self.showWarningCustomButton(
                    translation.getString("forgot_password_description") ?? "warning.forgotPassword".localized,
                    button: translation.getString("forgot_password_button") ?? "button.back".localized
                )
            } else {
                self.showWarningCustomButton("warning.forgotPassword".localized, button: "button.back".localized)
            }
            return
        }

        let loading = BlurryLoadingView.showAndStart()
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            loading.stopAndHide()
            if let error = error {
                self.show(error: error)
                return
            }

            let alertCompleted = UIAlertController(title: "Cambiar contraseña", message: "Se ha enviado un email a tu cuenta", preferredStyle: .alert)
            alertCompleted.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
            self.present(alertCompleted, animated: true, completion: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let registrationVC = segue.destination as? RegistrationViewController,
           let emailPassword = sender as? (String, String) {
            registrationVC.presetEmail = emailPassword.0
            registrationVC.presetPassword = emailPassword.1
        }
    }
}

extension PinelyLoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case tfEmail:
            tfPassword.becomeFirstResponder()

        case tfPassword:
            textField.resignFirstResponder()
            startSession()

        default:
            textField.resignFirstResponder()
        }
        return false
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.placeholder = nil
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case tfEmail:
            tfEmail.placeholder = "Haz click para escribir tu email"

        case tfPassword:
            tfPassword.placeholder = "Haz click para escribir tu contraseña"

        default:
            break
        }
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
            switch textField {
            case tfEmail, tfPassword:
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
