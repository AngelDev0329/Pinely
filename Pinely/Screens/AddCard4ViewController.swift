//
//  AddCard3ViewController.swift
//  Pinely
//

import UIKit
import SwiftEventBus
import FirebaseAnalytics

class AddCard4ViewController: AddCardViewController {
    @IBOutlet weak var tfCVV: UITextField!
    @IBOutlet weak var lblScanEntries: UILabel!
    @IBOutlet weak var lblText1Label: UILabel!
    @IBOutlet weak var lblText5Label: UILabel!
    @IBOutlet weak var lblButtonTitle: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        tfCVV.attributedPlaceholder = NSAttributedString(
            string: tfCVV.placeholder ?? "",
            attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.placeholderGray
            ]
        )

        localize()
    }

    private func localize() {
        guard let translation = AppDelegate.translation else {
            return
        }

        lblScanEntries.text = translation.getStringOrKey("add_creditcard_scan")
        lblText1Label.text = translation.getStringOrKey("add_creditcard_text1")
        lblText5Label.text = translation.getStringOrKey("add_creditcard_text5")
        lblButtonTitle.text = translation.getStringOrKey("add_creditcard_button2")
    }

    private func processAddCardResult(_ error: Error?) {
        if let error = error {
            switch error {
            case NetworkError.cardError:
                let alert = UIAlertController(title: "alert.ops".localized,
                                              message: "alert.cardRejected".localized,
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "button.reenter".localized, style: .cancel) { (_) in
                    if let addCardVC = self.navigationController?.viewControllers.first as? AddCardViewController {
                        addCardVC.reset()
                    }
                    self.navigationController?.popToRootViewController(animated: true)
                })
                self.present(alert, animated: true, completion: nil)

            case NetworkError.apiError(let errorText):
                let alert = UIAlertController(title: "alert.ops".localized, message: errorText, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "button.reenter".localized, style: .cancel) { (_) in
                    if let addCardVC = self.navigationController?.viewControllers.first as? AddCardViewController {
                        addCardVC.reset()
                    }
                    self.navigationController?.popToRootViewController(animated: true)
                })
                self.present(alert, animated: true, completion: nil)

            default:
                self.show(error: error)
            }
            return
        }

        Analytics.logEvent("add_payment_info", parameters: [:])
        SwiftEventBus.post("paymentMethodsUpdated")

        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func next() {
        self.skipIfFilled = false
        view.endEditing(true)
        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if self.cardCVV.count < 3 {
                self.showError("error.enterCorrectCVV".localized, delegate: {
                    // No action required
                }, title: "error.wrongCVV".localized)
                return
            }

            if self.cardCVV.count > 4 {
                self.showError("error.enterCorrectCVV".localized, delegate: {
                    // No action required
                }, title: "error.wrongCVV".localized)
                return
            }

            let loadingView = LoadingView.showAndRun(text: "loading.addingCard".localized, viewController: self)
            API.shared.addCard(name: self.cardName, number: self.cardNumber,
                               expMonth: self.cardMonth, expYear: self.cardYear,
                               cvc: self.cardCVV) { [weak self] (error) in
                loadingView?.stopAndRemove()
                self?.processAddCardResult(error)
            }
        }
    }

    override func reset() {
        super.reset()

        tfCVV.text = ""
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        tfCVV.becomeFirstResponder()
    }
}

extension AddCard4ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        next()
        return false
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.isFirstResponder {
            let lang = textField.textInputMode?.primaryLanguage
            if lang == "emoji" {
                return false
            }
        }

        guard let text = textField.text else { return true }

        if let textRange = Range(range, in: text) {
           let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            if updatedText.containsEmoji {
                return false
            }
        }

        let count = text.count + string.count - range.length

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            let newText = (textField.text ?? "").filter { (textChar) -> Bool in
                textChar.isNumber
            }
            self.cardCVV = newText
            self.showCardCVV()

            if count > 3 {
                textField.resignFirstResponder()
            }
        }
        return count <= 4 || string.count < range.length
    }
}
