//
//  ReferalViewController.swift
//  Pinely
//

import UIKit

class ReferalViewController: ViewController {
    @IBOutlet weak var aiLoading: UIActivityIndicatorView!

    @IBOutlet weak var vNotAvailableContainer: UIView!
    @IBOutlet weak var lblNotAvailableTitle: UILabel!
    @IBOutlet weak var lblNotAvailableDescription1: UILabel!
    @IBOutlet weak var lblNotAvailableDescription2: UILabel!

    @IBOutlet weak var vAvailableContainer: UIView!
    @IBOutlet weak var lblAvailableTitle: UILabel!
    @IBOutlet weak var lblAvailableDescription1: UILabel!
    @IBOutlet weak var lblAvailableDescription2: UILabel!
    @IBOutlet weak var lblAvailableDescription3: UILabel!
    @IBOutlet weak var lblPrincipalButton: UILabel!
    @IBOutlet weak var lblSecondaryButton: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        appDelegate.remoteConfig.fetchAndActivate { _, _ in
            if let referal = appDelegate.remoteConfig.configValue(forKey: "referal").stringValue,
               let referalDict = referal.asDict {
                self.showValues(using: referalDict)
            }
        }
    }

    private func prepareTextFrom(html: String) -> NSAttributedString? {
        guard let data = html.data(using: .unicode) else { return nil }
        guard let attributedString = try? NSAttributedString(
            data: data, options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil) else { return nil }

        let result = NSMutableAttributedString(attributedString: attributedString)

        attributedString.enumerateAttribute(.font, in: NSRange(location: 0, length: attributedString.length), options: []) { value, range, _ in
            guard let currentFont = value as? UIFont else {
                return
            }

            let font: UIFont
            if currentFont.fontName.lowercased().contains("bold") {
                font = AppFont.bold[13]
            } else {
                font = AppFont.regular[13]
            }
            result.addAttributes([.font: font], range: range)
        }

        if let color = UIColor(named: "MainForegroundColor") {
            result.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSRange(location: 0, length: result.length))
        }
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        result.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSRange(location: 0, length: result.length))
        return result
    }

    func makeReplacements(strings: [String], delegate: @escaping (_ strings: [String]) -> Void) {
        API.shared.checkReferal { refCode, amount, _ in
            var result: [String] = []
            let refCodeSafe = refCode ?? ""
            let amountSafe = amount.values.first ?? 0
            for string in strings {
                result.append(
                    string.replacingOccurrences(of: "$ref_code", with: refCodeSafe)
                        .replacingOccurrences(of: "$earnings", with: "\(amountSafe)")
                )
            }
            delegate(result)
        }
    }

    func showValues(using dict: [String: Any]) {
        let isAvailable = dict.getBoolean("available") ?? false

        lblNotAvailableTitle.text = dict.getString("title_not_available") ?? ""
        let dna1 = dict.getString("description_not_available1") ?? ""
        let dna2 = dict.getString("description_not_available2") ?? ""
        if let attributedString = prepareTextFrom(html: dna1) {
            lblNotAvailableDescription1.attributedText = attributedString
        } else {
            lblNotAvailableDescription1.text = dna1
        }
        if let attributedString = prepareTextFrom(html: dna2) {
            lblNotAvailableDescription2.attributedText = attributedString
        } else {
            lblNotAvailableDescription2.text = dna2
        }

        var descr1 = dict.getString("description1") ?? ""
        var descr2 = dict.getString("description2") ?? ""
        var descr3 = dict.getString("description3") ?? ""
        makeReplacements(strings: [descr1, descr2, descr3]) { [weak self] strings in
            guard let self = self else {
                return
            }

            descr1 = strings[0]
            descr2 = strings[1]
            descr3 = strings[2]
            self.lblAvailableTitle.text = dict.getString("title") ?? ""
            if let attributedString = self.prepareTextFrom(html: descr1) {
                self.lblAvailableDescription1.attributedText = attributedString
            } else {
                self.lblAvailableDescription1.text = descr1
            }
            if let attributedString = self.prepareTextFrom(html: descr2) {
                self.lblAvailableDescription2.attributedText = attributedString
            } else {
                self.lblAvailableDescription2.text = descr2
            }
            if let attributedString = self.prepareTextFrom(html: descr3) {
                self.lblAvailableDescription3.attributedText = attributedString
            } else {
                self.lblAvailableDescription3.text = descr3
            }
            self.lblPrincipalButton.text = dict.getString("button_principal") ?? ""
            self.lblSecondaryButton.text = dict.getString("button_secundary") ?? ""

            self.vAvailableContainer.isHidden = !isAvailable
            self.vNotAvailableContainer.isHidden = isAvailable

            self.aiLoading.stopAnimating()
        }
    }

    @IBAction func pressedPrimaryButton() {
        UIDevice.vibrate()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {

        }
    }

    @IBAction func pressedSecondaryButton() {
        UIDevice.vibrate()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.performSegue(withIdentifier: "ReferalLink", sender: self)
        }
    }
}
