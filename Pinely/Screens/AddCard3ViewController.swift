//
//  AddCard3ViewController.swift
//  Pinely
//

import UIKit

class AddCard3ViewController: AddCardViewController {
    @IBOutlet weak var tfMonthYear: UITextField!
    @IBOutlet weak var lblScanEntries: UILabel!
    @IBOutlet weak var lblNameTitle: UILabel!
    @IBOutlet weak var lblExpirationTitle: UILabel!
    @IBOutlet weak var lblText1Label: UILabel!
    @IBOutlet weak var lblText3Label: UILabel!
    @IBOutlet weak var lblButtonTitle: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        tfMonthYear.attributedPlaceholder = NSAttributedString(
            string: tfMonthYear.placeholder ?? "",
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
        lblText3Label.text = translation.getStringOrKey("add_creditcard_text3")
        lblButtonTitle.text = translation.getStringOrKey("add_creditcard_button1")
    }

    @IBAction func next() {
        view.endEditing(true)
        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.performSegue(withIdentifier: "next", sender: self)
        }
    }

    override func reset() {
        super.reset()

        if !cardMonth.isEmpty && !cardYear.isEmpty {
            tfMonthYear.text = "\(cardMonth)/\(cardYear)"
        } else {
            tfMonthYear.text = ""
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !cardMonth.isEmpty && !cardYear.isEmpty {
            tfMonthYear.text = "\(cardMonth)/\(cardYear)"
        } else {
            tfMonthYear.text = ""
        }

        if !(tfMonthYear.text ?? "").isEmpty && skipIfFilled {
            self.performSegue(withIdentifier: "next", sender: self)
        } else {
            tfMonthYear.becomeFirstResponder()
        }
    }
}

extension AddCard3ViewController: UITextFieldDelegate {
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
            var newText = (textField.text ?? "").filter { (textChar) -> Bool in
                textChar.isNumber
            }
            if newText.count <= 2 {
                self.cardMonth = newText
                self.cardYear = ""
            } else {
                self.cardMonth = String(newText[0..<2])
                self.cardYear = String(newText[2...])
                newText = "\(self.cardMonth)/\(self.cardYear)"

                if newText.count >= 5 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.next()
                    }
                }
            }

            self.tfMonthYear.text = newText
            self.showCardMonthYear()
        }
        return count <= 5
    }
}
