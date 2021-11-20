//
//  EditProfileViewController.swift
//  Pinely
//

import UIKit
import FirebaseAuth
import SwiftEventBus

class EditProfileViewController: ViewController {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblSurname: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblPhone: UILabel!
    @IBOutlet weak var lblAge: UILabel!
    @IBOutlet weak var lblDNI: UILabel!
    @IBOutlet weak var lblSaveChanges: UILabel!

    @IBOutlet weak var ivProfilePicture: UIImageView!
    @IBOutlet weak var tfFirstName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var tfPhone: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfDOB: UITextField!
    @IBOutlet weak var tfDNI: UITextField!

    @IBOutlet weak var lcFirstNameVerified: NSLayoutConstraint!
    @IBOutlet weak var lcLastNameVerified: NSLayoutConstraint!
    @IBOutlet weak var lcEmailVerified: NSLayoutConstraint!
    @IBOutlet weak var lcPhoneVerified: NSLayoutConstraint!
    @IBOutlet weak var lcDOBVerified: NSLayoutConstraint!
    @IBOutlet weak var lcDNIVerified: NSLayoutConstraint!

    @IBOutlet weak var ivFirstNameVerified: UIImageView!
    @IBOutlet weak var ivLastNameVerified: UIImageView!
    @IBOutlet weak var ivEmailVerified: UIImageView!
    @IBOutlet weak var ivPhoneVerified: UIImageView!
    @IBOutlet weak var ivDOBVerified: UIImageView!
    @IBOutlet weak var ivDNIVerified: UIImageView!

    @IBOutlet weak var btnFirstNameVerified: UIButton!
    @IBOutlet weak var btnLastNameVerified: UIButton!
    @IBOutlet weak var btnDOBVerified: UIButton!
    @IBOutlet weak var btnDNIVerified: UIButton!
    @IBOutlet weak var btnPhoneVerified: UIButton!

    @IBOutlet weak var aiLoading1: UIActivityIndicatorView!
    @IBOutlet weak var aiLoading2: UIActivityIndicatorView!
    @IBOutlet weak var aiLoading3: UIActivityIndicatorView!
    @IBOutlet weak var aiLoading4: UIActivityIndicatorView!
    @IBOutlet weak var aiLoading5: UIActivityIndicatorView!
    @IBOutlet weak var aiLoading6: UIActivityIndicatorView!

    var selectedDOB: Date?
    let dateFormatter = DateFormatter()
    var profile: Profile?

    let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 216))

    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateFormat = "dd/MM/yyyy"

        if let photoUrl = Auth.auth().currentUser?.photoURL {
            ivProfilePicture.backgroundColor = .clear
            ivProfilePicture.kf.setImage(with: photoUrl)
        } else {
            ivProfilePicture.image = #imageLiteral(resourceName: "AvatarPinely")
        }

        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "es-ES")
        datePicker.date = Date(timeIntervalSince1970: 780019200)
        tfDOB.inputView = datePicker

        datePicker.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)

        addDoneButtonOnKeyboard(textField: tfDOB, action: #selector(self.doneButtonAction))
        addDoneButtonOnKeyboard(textField: tfDNI, action: #selector(self.doneButtonActionGeneric))
        addDoneButtonOnKeyboard(textField: tfFirstName, action: #selector(self.doneButtonActionGeneric))
        addDoneButtonOnKeyboard(textField: tfLastName, action: #selector(self.doneButtonActionGeneric))
        addDoneButtonOnKeyboard(textField: tfPhone, action: #selector(self.doneButtonActionGeneric))
        addDoneButtonOnKeyboard(textField: tfEmail, action: #selector(self.doneButtonActionGeneric))

        tfEmail.text = Auth.auth().currentUser?.email
        if !(tfEmail.text ?? "").isEmpty {
            aiLoading6.stopAnimating()
        }

        if profile == nil {
            loadProfile()
        } else {
            showProfile()
        }

        localize()
    }

    private func localize() {
        guard let translation = AppDelegate.translation else {
            return
        }

        lblTitle.text = translation.getStringOrKey("edit_profile_title")
        lblName.text = translation.getStringOrKey("edit_profile_name")
        lblSurname.text = translation.getStringOrKey("edit_profile_surname")
        lblEmail.text = translation.getStringOrKey("edit_profile_email")
        lblPhone.text = translation.getStringOrKey("edit_profile_telephone")
        lblAge.text = translation.getStringOrKey("edit_profile_age")
        lblSaveChanges.text = translation.getStringOrKey("edit_profile_savechanges")
    }

    func addDoneButtonOnKeyboard(textField: UITextField, action: Selector?) {
        let toolbarFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50)
        let doneToolbar = UIToolbar(frame: toolbarFrame)
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Aceptar", style: .done, target: self, action: action)

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        textField.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonActionGeneric() {
        if tfFirstName.isFirstResponder {
            view.endEditing(true)
        } else if tfLastName.isFirstResponder {
            view.endEditing(true)
        } else if tfPhone.isFirstResponder {
            if tfEmail.isEnabled {
                tfEmail.becomeFirstResponder()
            } else {
                view.endEditing(true)
            }
        } else if tfEmail.isFirstResponder {
            tfDOB.becomeFirstResponder()
        } else if tfDOB.isFirstResponder {
            tfDNI.becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
    }

    @objc func doneButtonAction() {
        tfDOB.text = dateFormatter.string(from: datePicker.date)
        selectedDOB = datePicker.date
        view.endEditing(true)
    }

    @objc func handleDatePicker(sender: UIDatePicker) {
        tfDOB.text = dateFormatter.string(from: sender.date)
        selectedDOB = sender.date
    }

    func loadProfile() {
        API.shared.loadUserInfo(force: true) { [weak self] (_, error) in
            if let error = error {
                [self?.aiLoading1, self?.aiLoading2, self?.aiLoading3,
                 self?.aiLoading4, self?.aiLoading5, self?.aiLoading6].forEach {
                    $0?.stopAnimating()
                }
                self?.show(error: error)
            } else {
                self?.showProfile()
            }
        }
    }

    func showProfile() {
        [aiLoading1, aiLoading2, aiLoading3,
         aiLoading4, aiLoading5, aiLoading6].forEach {
            $0?.stopAnimating()
        }
        tfFirstName.text = profile?.name ?? ""
        tfLastName.text = profile?.lastName ?? ""
        tfPhone.text = profile?.mobilePhone ?? ""
        tfDNI.text = profile?.dniNumber ?? ""
        if let dateOfBirth = profile?.getDOB() {
            selectedDOB = dateOfBirth
            datePicker.date = dateOfBirth
            tfDOB.text = dateFormatter.string(from: dateOfBirth)
        } else {
            selectedDOB = nil
            tfDOB.text = ""
        }

        if profile?.dniVerification == "completed" {
            setDNIVerified()
        } else {
            setDNINotVerified()
        }
        if profile?.smsVerification == "verified" {
            setPhoneVerified()
        } else {
            setPhoneNotVerified()
        }
        if Auth.auth().currentUser?.isEmailVerified == true {
            setEmailVerified()
        } else {
            setEmailNotVerified()
        }
    }

    func setEmailVerified() {
        lcEmailVerified.constant = min(
            tfEmail.bounds.width - 4,
            (tfEmail.text ?? "")
                .width(withConstrainedHeight: 100, font: tfPhone.font!) + 4)
        ivEmailVerified.isHidden = false

        tfEmail.isEnabled = false

        view.layoutIfNeeded()
    }

    func setEmailNotVerified() {
        ivEmailVerified.isHidden = true
    }

    func setPhoneVerified() {
        lcPhoneVerified.constant = min(
            tfPhone.bounds.width - 4,
            (tfPhone.text ?? "")
                .width(withConstrainedHeight: 100, font: tfPhone.font!) + 4)
        ivPhoneVerified.isHidden = false

        tfPhone.isEnabled = false

        view.layoutIfNeeded()
    }

    func setPhoneNotVerified() {
        ivPhoneVerified.isHidden = true
    }

    func setDNIVerified() {
        tfFirstName.isEnabled = false
        tfLastName.isEnabled = false
        tfDNI.isEnabled = false
        tfDOB.isEnabled = false

        lcFirstNameVerified.constant = -min(
            tfFirstName.bounds.width - 4,
            (tfFirstName.text ?? "")
                .width(withConstrainedHeight: 100, font: tfFirstName.font!) + 4)
        lcLastNameVerified.constant = min(
            tfLastName.bounds.width - 4,
            (tfLastName.text ?? "")
                .width(withConstrainedHeight: 100, font: tfLastName.font!) + 4)
        lcDOBVerified.constant = min(
            tfDOB.bounds.width - 4,
            (tfDOB.text ?? "")
                .width(withConstrainedHeight: 100, font: tfDOB.font!) + 4)
        lcDNIVerified.constant = min(
            tfDNI.bounds.width - 4,
            (tfDNI.text ?? "")
                .width(withConstrainedHeight: 100, font: tfDNI.font!) + 4)

        ivFirstNameVerified.isHidden = false
        ivLastNameVerified.isHidden = false
        ivDOBVerified.isHidden = false
        ivDNIVerified.isHidden = false

        btnFirstNameVerified.isHidden = false
        btnLastNameVerified.isHidden = false
        btnDOBVerified.isHidden = false
        btnDNIVerified.isHidden = false

        btnFirstNameVerified.addTarget(self, action: #selector(showVerifiedUps), for: .touchUpInside)
        btnLastNameVerified.addTarget(self, action: #selector(showVerifiedUps), for: .touchUpInside)
        btnDOBVerified.addTarget(self, action: #selector(showVerifiedUps), for: .touchUpInside)
        btnDNIVerified.addTarget(self, action: #selector(showVerifiedUps), for: .touchUpInside)

        view.layoutIfNeeded()
    }

    func setDNINotVerified() {
        tfFirstName.isEnabled = true
        tfLastName.isEnabled = true
        tfDNI.isEnabled = true
        tfDOB.isEnabled = true

        ivFirstNameVerified.isHidden = true
        ivLastNameVerified.isHidden = true
        ivDOBVerified.isHidden = true
        ivDNIVerified.isHidden = true

        btnFirstNameVerified.isHidden = true
        btnLastNameVerified.isHidden = true
        btnDOBVerified.isHidden = true
        btnDNIVerified.isHidden = true
    }

    @objc func showVerifiedUps() {
        let alert = UIAlertController(title: "alert.ops".localized,
                                      message: "alert.accountInRevision".localized,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    @IBAction func saveChanges() {
        view.endEditing(true)
        UIDevice.vibrate()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            var profile = Profile()
            profile.name = self.tfFirstName.text
            profile.lastName = self.tfLastName.text
            profile.mobilePhone = self.tfPhone.text
            if let dateOfBirth = self.selectedDOB {
                profile.setDOB(date: dateOfBirth)
            }
            profile.dniNumber = self.tfDNI.text

            let loading = BlurryLoadingView.showAndStart()
            API.shared.updateUserInfo(profile: profile) { (error) in
                loading.stopAndHide()
                if let error = error {
                    self.show(error: error)
                } else {
                    SwiftEventBus.post("profileChanged")
                    self.goBack()
                }
            }
        }
    }
}

extension EditProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case tfFirstName:
            tfLastName.becomeFirstResponder()

        case tfLastName:
            if tfPhone.isEnabled {
                tfPhone.becomeFirstResponder()
            } else {
                tfDOB.becomeFirstResponder()
            }

        case tfPhone:
            tfDOB.becomeFirstResponder()

        case tfDOB:
            tfDNI.becomeFirstResponder()

        default:
            textField.resignFirstResponder()
        }

        return false
    }

    private func validateInput(_ updatedText: String, _ textField: UITextField) -> Bool {
        if updatedText.containsEmoji {
            return false
        }

        switch textField {
        case tfFirstName:
            if updatedText.count > 30 {
                return false
            }

        case tfLastName, tfPhone:
            if updatedText.count > 45 {
                return false
            }

        default:
            break
        }

        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty {
            return true
        }
        if string.containsEmoji {
            return false
        }

        if textField.isFirstResponder {
            let lang = textField.textInputMode?.primaryLanguage
            if lang == "emoji" {
                return false
            }
        }

        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            return validateInput(updatedText, textField)
        }
        return true
    }
}
