//
//  ChangeNicknameViewController.swift
//  Pinely
//

import UIKit
import Kingfisher
import FirebaseAuth
import SwiftEventBus

class ChangeNicknameViewController: ViewController {
    @IBOutlet weak var tfNickname: UITextField!
    @IBOutlet weak var ivProfilePicture: UIImageView!
    @IBOutlet weak var lcBottom: NSLayoutConstraint!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnChange: UIButton!
    
    var oldNickname = ""
    var popupTitle: String?
    var popupDesc: String?
    var popupButtonText: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        tfNickname.text = self.oldNickname

        if let photoUrl = Auth.auth().currentUser?.photoURL {
            ivProfilePicture.backgroundColor = .clear
            ivProfilePicture.kf.setImage(with: photoUrl)
        } else {
            ivProfilePicture.image = #imageLiteral(resourceName: "AvatarPinely")
        }

        localize()
    }

    private func localize() {
        guard let translation = AppDelegate.translation else {
            return
        }
        lblTitle.text = translation.getStringOrKey("profile_change_username")
        btnChange.setTitle(translation.getStringOrKey("change_username_button"), for: .normal)
        popupTitle = translation.getStringOrKey("change_username_popup_title")
        popupDesc = translation.getStringOrKey("change_username_popup_description")
        popupButtonText = translation.getStringOrKey("change_username_popup_button")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow(notification:)),
            name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification, object: nil)

        tfNickname.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        view.endEditing(true)

        NotificationCenter.default.removeObserver(self)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        let keyboardHeight = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 320
        var inset: CGFloat = -keyboardHeight - 8
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            let bottomPadding = window?.safeAreaInsets.bottom
            inset += bottomPadding ?? 0
        }

       self.lcBottom.constant = inset
       UIView.animate(withDuration: 0.3) {
           self.view.layoutIfNeeded()
       }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.lcBottom.constant = 8
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }

    func applyChange() {
        view.endEditing(true)

        var nickname = tfNickname.textPrepared
        if nickname.count < 4 {
            showWarning("Tu usuario tiene que ser un poco más largo", title: "alert.ops".localized)
            return
        }

        nickname = nickname.lowercased()
        tfNickname.text = nickname

        let loading = BlurryLoadingView.showAndStart()
        API.shared.changeUsername(username: nickname) { (error) in
            loading.stopAndHide()
            if let error = error {
                self.show(error: error)
            } else {
                SwiftEventBus.post("profileChanged")
                self.goBack()
            }
        }
    }

    @IBAction func paraque() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let alert = UIAlertController(title: self.popupTitle ?? "Tu usuario",
                                          message: self.popupDesc ?? "Sirve para que tu amigos o gente conocida te encuentre facilmente",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: self.popupButtonText ?? "Entendido", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension ChangeNicknameViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        applyChange()
        return false
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if string.isEmpty {
            return true
        }
        if string.containsEmoji {
            return false
        }

        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            if updatedText.isEmpty {
                return true
            } else if updatedText.count > 20 {
                return false
            } else if updatedText.contains(" ") {
                return false
            } else if !updatedText.isAlphanumeric {
                return false
            }
            if updatedText != updatedText.lowercased() {
                DispatchQueue.main.async {
                    textField.text = updatedText.lowercased()
                }
            }
        }
        return true
    }
}
