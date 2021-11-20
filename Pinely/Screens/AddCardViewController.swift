//
//  AddCardViewController.swift
//  Pinely
//

import UIKit
import CardScan

class AddCardViewController: ViewController {
    @IBOutlet weak var lblCard: UILabel?
    @IBOutlet weak var lblName: UILabel?
    @IBOutlet weak var lblMonthYear: UILabel?
    @IBOutlet weak var lblCVV: UILabel?
    @IBOutlet weak var ivCardLogo: UIImageView?

    var cardNumber = ""
    var cardName = ""
    var cardMonth = ""
    var cardYear = ""
    var cardCVV = ""

    var skipIfFilled = false

    let fontNotFilled = AppFont.regular[11]
    let fontFilled = AppFont.bold[11]

    override func viewDidLoad() {
        super.viewDidLoad()

        showCardNumber()
        showCardName()
        showCardMonthYear()
        showCardCVV()
        showCardLogo()
    }

    func showCardLogo() {
        let cardType = CardType.getTypeByFirstNumbers(number: self.cardNumber)
        ivCardLogo?.image = cardType?.image
    }

    func reset() {
        cardName = ""
        cardNumber = ""
        cardYear = ""
        cardMonth = ""
        cardCVV = ""
        showCardNumber()
        showCardName()
        showCardMonthYear()
        showCardCVV()
    }

    func showCardNumber() {
        if cardNumber.isEmpty {
            lblCard?.text = "XXXX XXXX XXXX XXXX"
        } else {
            lblCard?.text = cardNumber
        }
    }

    func showCardName() {
        if cardName.isEmpty {
            lblName?.font = fontNotFilled
            lblName?.text = AppDelegate.translation?.getString("add_creditcard_titular_sub") ?? "NOMBRE APELLIDOS"
        } else {
            lblName?.font = fontFilled
            lblName?.text = cardName
        }
    }

    func showCardMonthYear() {
        if cardMonth.isEmpty && cardYear.isEmpty {
            lblMonthYear?.font = fontNotFilled
            lblMonthYear?.text = "MM/YY"
        } else {
            lblMonthYear?.font = fontFilled
            lblMonthYear?.text = "\(cardMonth)/\(cardYear)"
        }
    }

    func showCardCVV() {
        lblCVV?.text = self.cardCVV
    }

    @IBAction func doScanCard() {
        view.endEditing(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            guard let scanVC = ScanViewController.createViewController(withDelegate: self) else {
                print("This device is incompatible with CardScan")
                return
            }

            scanVC.allowSkip = false
            scanVC.stringDataSource = self

            scanVC.scanCardFont = AppFont.semiBold[20]
            scanVC.positionCardFont = AppFont.regular[15]

            scanVC.torchButtonImage = #imageLiteral(resourceName: "CardscanTorch")
            scanVC.backButtonImage = #imageLiteral(resourceName: "back_arrow_white")

            scanVC.cornerColor = UIColor.white

            self.present(scanVC, animated: true)
        }
    }

    @IBAction func exit() {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }

    func cardScanned() {
        lblMonthYear?.font = fontFilled

        lblCard?.text = cardNumber
        lblMonthYear?.text = "\(cardMonth)/\(cardYear)"

        showCardLogo()
        self.skipIfFilled = true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addCardVC = segue.destination as? AddCardViewController {
            addCardVC.cardNumber = cardNumber
            addCardVC.cardName = cardName
            addCardVC.cardMonth = cardMonth
            addCardVC.cardYear = cardYear
            addCardVC.cardCVV = cardCVV
            addCardVC.skipIfFilled = self.skipIfFilled
            self.skipIfFilled = false
        }
    }
}

extension AddCardViewController: ScanDelegate, ScanStringsDataSource {
    func scanCard() -> String {
        "Tu tarjeta aquí"
    }

    func positionCard() -> String {
        "Coloca tu tarjeta sobre el marco para que podamos escanearla automáticamente"
    }

    func backButton() -> String {
        ""
    }

    func skipButton() -> String {
        ""
    }

    func userDidCancel(_ scanViewController: ScanViewController) {
        self.dismiss(animated: true)
    }

    func userDidScanCard(_ scanViewController: ScanViewController, creditCard: CreditCard) {
        let number = creditCard.number
        var expiryMonth = creditCard.expiryMonth ?? ""
        var expiryYear = creditCard.expiryYear ?? ""

        if expiryMonth.count == 1 {
            expiryMonth = "0\(expiryMonth)"
        }

        if expiryYear.count == 4 {
            let startIndex = expiryYear.index(expiryYear.startIndex, offsetBy: 2)
            expiryYear = String(expiryYear.suffix(from: startIndex))
        }

        var numberProcessed = number.replacingOccurrences(
            of: "^[\\s-]*([0-9]{4})[\\s-]*([0-9]{4})[\\s-]*([0-9]{4})[\\s-]*([0-9]{4})[\\s-]*([0-9]{3})[\\s-]*$",
            with: "$1 $2 $3 $4 $5",
            options: .regularExpression,
            range: nil)

        if numberProcessed == number {
            numberProcessed = number.replacingOccurrences(
                of: "^[\\s-]*([0-9]{4})[\\s-]*([0-9]{4})[\\s-]*([0-9]{4})[\\s-]*([0-9]{4})[\\s-]*$",
                with: "$1 $2 $3 $4",
                options: .regularExpression,
                range: nil)
        }

        cardNumber = numberProcessed.trimmingCharacters(in: .whitespacesAndNewlines)
        cardMonth = expiryMonth.trimmingCharacters(in: .whitespacesAndNewlines)
        cardYear = expiryYear.trimmingCharacters(in: .whitespacesAndNewlines)

        cardScanned()

        self.dismiss(animated: true)
    }

    func userDidSkip(_ scanViewController: ScanViewController) {
        self.dismiss(animated: true)
    }
}
