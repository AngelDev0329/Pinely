//
//  MobileVerificationViewController.swift
//  Pinely
//

import UIKit
import CountryPickerView
import libPhoneNumber_iOS

class MobileVerificationViewController: ViewController {
    @IBOutlet weak var lblCountryCode: UILabel!
    @IBOutlet weak var ivFlag: UIImageView!
    @IBOutlet weak var lcCountryCodeOffset: NSLayoutConstraint!
    @IBOutlet weak var tfPhone: UITextField!
    @IBOutlet weak var vNextButtonContainer: UIView!
    @IBOutlet weak var lcNextButtonButton: NSLayoutConstraint!
    @IBOutlet weak var vPhoneContainer: UIView!

    var ipInfo: IpInfo?
    var countryCode: String!
    var locale: String!
    let phoneUtil = NBPhoneNumberUtil()

    override func viewDidLoad() {
        super.viewDidLoad()

        locale = ipInfo?.countryCode ?? "ES"
        let countries = CountrySelectView.shared.searchCountrys ?? []
        let countryDict =  countries.first(where: { $0.getString("locale") == locale })
        countryCode = "+" + (countryDict?.getString("code") ?? "")

        ivFlag.image = UIImage(named: "CountryPicker.bundle/\(locale.uppercased())")
        showCountryCode(phone: tfPhone.text ?? "")

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.tfPhone.becomeFirstResponder()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        let targetFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        let window = UIApplication.shared.windows[0]
        lcNextButtonButton.constant = (targetFrame?.height ?? 320) + 8 - window.safeAreaInsets.bottom
        view.layoutIfNeeded()
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        lcNextButtonButton.constant = 8
    }

    func countrySelected(countryDic: [String: Any]) {
        self.countryCode = "+" + (countryDic.getString("code") ?? "")
        var image = countryDic["countryImage"] as? UIImage
        if let locale = countryDic.getString("locale") {
            self.locale = locale
            if image == nil {
                image = UIImage(named: "CountryPicker.bundle/\(locale)")
            }
        }
        self.ivFlag.image = image
        self.showCountryCode(phone: self.tfPhone.text ?? "")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.tfPhone.becomeFirstResponder()
        }
    }

    @IBAction func chooseCountry() {
        view.endEditing(true)
        self.performSegue(withIdentifier: "ChooseCountryCode", sender: self)
    }

    func showCountryCode(phone: String) {
        lblCountryCode.text = countryCode
        let fullText = countryCode + phone
        lcCountryCodeOffset.constant = -fullText.width(withConstrainedHeight: 24, font: lblCountryCode.font) / 2
        vPhoneContainer.setNeedsLayout()
        vPhoneContainer.layoutIfNeeded()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mobileVerificationConfirmationVC =
            segue.destination as? MobileVerificationConfirmationViewController {
            mobileVerificationConfirmationVC.phoneNumber = countryCode + (tfPhone.text ?? "")
        }
    }

    @IBAction func next() {
        view.endEditing(true)
        let mobilePhone = countryCode + (tfPhone.text ?? "")
        let loading = BlurryLoadingView.showAndStart()
        API.shared.sendSMSVerification(mobilePhone: mobilePhone) { (error) in
            loading.stopAndHide()
            if let error = error {
                self.show(error: error)
            } else {
                self.performSegue(withIdentifier: "MobileVerificationConfirmation", sender: self)
            }
        }
    }
}

extension MobileVerificationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
           let textRange = Range(range, in: text) {
           let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            if !updatedText.isEmpty && !updatedText.containsOnlyDigits {
                return false
            }

            showCountryCode(phone: updatedText)
            if (self.locale == "ES" && updatedText.count > 9) || updatedText.count > 16 {
                return false
            }
        }
        return true
    }
}
