//
//  SupportRequestViewController.swift
//  Pinely
//

import UIKit
import FirebaseAuth

class SupportRequestViewController: ViewController {
    @IBOutlet weak var tfMessageText: UITextField!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblButtonTitle: UILabel!
    @IBOutlet weak var lcBottom: NSLayoutConstraint!

    var screenTitle: String?
    var screenDescription: String?
    var inputText: String?
    var buttonText: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        lblTitle.text = screenTitle ?? lblTitle.text
        lblMessage.text = inputText ?? lblMessage.text
        tfMessageText.placeholder = inputText ?? tfMessageText.placeholder
        lblButtonTitle.text = buttonText ?? lblButtonTitle.text

        let email = Auth.auth().currentUser?.email ?? ""
        let descriptionText = (screenDescription ?? "supportRequestDescription".localized)
            .replacingOccurrences(of: "$email_user", with: email)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 12.0
        paragraphStyle.alignment = .center
        lblDescription.attributedText = NSAttributedString(string: descriptionText, attributes: [
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ])
    }

    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        registerKeyboardNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func sendRequest() {
        view.endEditing(true)
        UIDevice.vibrate()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // TODO: Send support request
        }
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue
        let keyboardSize = keyboardInfo?.cgRectValue.size
        lcBottom.constant = (keyboardSize?.height ?? 320) + 18
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        lcBottom.constant = 8
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

extension SupportRequestViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
