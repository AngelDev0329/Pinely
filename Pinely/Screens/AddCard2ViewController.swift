//
//  AddCard2ViewController.swift
//  Pinely
//

import UIKit

class AddCard2ViewController: AddCardViewController {
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var lblScanEntries: UILabel!
    @IBOutlet weak var lblNameTitle: UILabel!
    @IBOutlet weak var lblExpirationTitle: UILabel!
    @IBOutlet weak var lblText1Label: UILabel!
    @IBOutlet weak var lblText4Label: UILabel!
    @IBOutlet weak var lblButtonTitle: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        tfName.attributedPlaceholder = NSAttributedString(
            string: tfName.placeholder ?? "",
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
        lblText4Label.text = translation.getStringOrKey("add_creditcard_text4")
        lblButtonTitle.text = translation.getStringOrKey("add_creditcard_button1")
    }

    @IBAction func next() {
        view.endEditing(true)
        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if self.cardName.count < 7 {
                self.showError("error.enterCorrectCardName".localized,
                               delegate: {
                                   // No action required
                               },
                               title: "error.wrongName".localized)
                return
            }

            self.performSegue(withIdentifier: "next", sender: self)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        tfName.becomeFirstResponder()
    }

    override func reset() {
        super.reset()

        tfName.text = ""
    }
}

extension AddCard2ViewController: UITextFieldDelegate {
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
            if string.contains(where: { $0.isLowercase }) {
                return false
            }
        }

        if let text = textField.text,
                  let textRange = Range(range, in: text) {
                   let updatedText = text.replacingCharacters(in: textRange, with: string)
            if updatedText.containsEmoji {
                return false
            }
            if updatedText.count > 35 {
                return false
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.cardName = (textField.text ?? "").uppercased()
            self.showCardName()
        }
        return true
    }
}
