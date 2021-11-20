//
//  AddCard1ViewController.swift
//  Pinely
//

import UIKit

class AddCard1ViewController: AddCardViewController {
    @IBOutlet weak var tfCard: UITextField!
    @IBOutlet weak var lblScanEntries: UILabel!
    @IBOutlet weak var lblNameTitle: UILabel!
    @IBOutlet weak var lblExpirationTitle: UILabel!
    @IBOutlet weak var lblText1Label: UILabel!
    @IBOutlet weak var lblText2Label: UILabel!
    @IBOutlet weak var lblButtonTitle: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        tfCard.attributedPlaceholder = NSAttributedString(
            string: tfCard.placeholder ?? "",
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
        lblNameTitle.text = translation.getStringOrKey("add_creditcard_titular")
        lblExpirationTitle.text = translation.getStringOrKey("add_creditcard_date")
        lblText1Label.text = translation.getStringOrKey("add_creditcard_text1")
        lblText2Label.text = translation.getStringOrKey("add_creditcard_text2")
        lblButtonTitle.text = translation.getStringOrKey("add_creditcard_button1")
    }

    @IBAction func next() {
        view.endEditing(true)
        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let ccNumber = self.cardNumber.replacingOccurrences(of: " ", with: "")
            if ccNumber.count < 13 {
                self.showWarning("warning.enterCard".localized, title: "warning.wrongNumber".localized)
            } else {
                self.performSegue(withIdentifier: "next", sender: self)
            }
        }
    }

    override func reset() {
        super.reset()

        tfCard.text = ""
    }

    override func cardScanned() {
        super.cardScanned()

        tfCard.text = cardNumber
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        tfCard.becomeFirstResponder()
    }
}

extension AddCard1ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        next()
        return false
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }

        if textField.isFirstResponder {
            let lang = textField.textInputMode?.primaryLanguage
            if lang == "emoji" {
                return false
            }
        }

        var ccNumber = text.replacingOccurrences(of: " ", with: "")
        if let text = textField.text,
           let textRange = Range(range, in: text) {
           let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            if updatedText.containsEmoji {
                return false
            }
            ccNumber = updatedText.replacingOccurrences(of: " ", with: "")
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            let formatter = CreditCardFormatter.shared
            formatter.formatToCreditCardNumber(
                textField: self.tfCard,
                withPreviousTextContent: text,
                andPreviousCursorPosition: textField.selectedTextRange)

            self.cardNumber = textField.text ?? ""

            self.showCardNumber()
            self.showCardLogo()

            if ccNumber.count >= 19 {
                textField.resignFirstResponder()
            }
        }
        return ccNumber.count < 19 || string.count <= range.length
    }
}
