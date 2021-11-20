//
//  MobileVerificationConfirmationViewController.swift
//  Pinely
//

import UIKit

// swiftlint:disable type_name
class MobileVerificationConfirmationViewController: ViewController {
    @IBOutlet weak var lblPhoneNumber: UILabel!
    @IBOutlet weak var tfDigit1: UITextField!
    @IBOutlet weak var tfDigit2: UITextField!
    @IBOutlet weak var tfDigit3: UITextField!
    @IBOutlet weak var tfDigit4: UITextField!

    var phoneNumber = ""
    var verifyingNow = false

    override func viewDidLoad() {
        super.viewDidLoad()

        lblPhoneNumber.text = phoneNumber

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.tfDigit1.becomeFirstResponder()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        tfDigit1.becomeFirstResponder()
    }

    private func processValidationResult(validated: Bool) {
        if !validated {
            self.verifyingNow = false
            self.showError("El código que has introducido es incorrecto, inténtalo de nuevo")
            return
        }

        if (self.navigationController?.viewControllers ?? []).count == 2 {
            self.navigationController?.dismiss(animated: true, completion: nil)
        } else {
            var viewControllers: [UIViewController] = []
            var wasAccount = false
            for viewController in self.navigationController?.viewControllers ?? [] {
                if let profileVC = viewController as? ProfileViewController {
                    // Account screen
                    profileVC.checkMobileVerification()
                    wasAccount = true
                    viewControllers.append(profileVC)
                } else if !wasAccount {
                    // Before account screen
                    viewControllers.append(viewController)
                }
            }
            viewControllers.append(self)
            self.navigationController?.viewControllers = viewControllers
            self.navigationController?.popViewController(animated: true)
        }
    }

    func verify() {
        view.endEditing(true)
        if verifyingNow {
            return
        }

        tfDigit1.isEnabled = false
        tfDigit2.isEnabled = false
        tfDigit3.isEnabled = false
        tfDigit4.isEnabled = false

        var code = tfDigit1.text ?? ""
        code += tfDigit2.text ?? ""
        code += tfDigit3.text ?? ""
        code += tfDigit4.text ?? ""

        let loading = BlurryLoadingView.showAndStart()
        verifyingNow = true
        API.shared.checkSMS(mobilePhone: phoneNumber, code: code) { [weak self] (validated, error) in
            loading.stopAndHide()
            if let error = error {
                self?.verifyingNow = false
                self?.show(error: error)
            } else {
                self?.processValidationResult(validated: validated)
            }
        }
    }

    @IBAction func didntReceive() {
        view.endEditing(true)
        let alert = UIAlertController(
            title: "alert.attention".localized,
            message: "alert.incorrectPhoneNumber".localized,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "button.understood".localized, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension MobileVerificationConfirmationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            if (textField.text ?? "").count > 0 {
                _ = self.textFieldShouldReturn(textField)
            }
        }
        return true
    }

    func nextTextField(_ textField: UITextField) -> UITextField? {
        switch textField {
        case tfDigit1: return tfDigit2
        case tfDigit2: return tfDigit3
        case tfDigit3: return tfDigit4
        default: return nil
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text ?? "").count > 1 {
            let text = textField.text ?? ""
            textField.text = String(text[0..<1])
            var tail = String(text[1...])
            var tfNext = nextTextField(textField)
            while tfNext != nil && tail.count > 0 {
                tfNext!.text = String(tail[0..<1])
                if tail.count == 1 {
                    tfNext = nextTextField(tfNext!)
                    break
                }
                tail = String(tail[1...])
                tfNext = nextTextField(tfNext!)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                if tfNext == nil {
                    self.view.endEditing(true)
                } else {
                    tfNext?.becomeFirstResponder()
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            if self.tfDigit1.text?.count == 1,
               self.tfDigit2.text?.count == 1,
               self.tfDigit3.text?.count == 1,
               self.tfDigit4.text?.count == 1 {
                self.view.endEditing(true)
                self.verify()
            }
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case tfDigit1: tfDigit2.becomeFirstResponder()
        case tfDigit2: tfDigit3.becomeFirstResponder()
        case tfDigit3: tfDigit4.becomeFirstResponder()
        case tfDigit4:
            verify()
            textField.resignFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return false
    }
}
