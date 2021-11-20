//
//  ProfileViewController.swift
//  Pinely
//

import UIKit
import Kingfisher
import FirebaseAuth
import FirebaseStorage
import SwiftEventBus
import FirebaseRemoteConfig

// swiftlint:disable type_body_length
// swiftlint:disable file_length
// swiftlint:disable function_body_length
class ProfileViewController: ViewController {
    @IBOutlet weak var ivProfilePictureShadow: UIImageView!
    @IBOutlet weak var ivProfilePicture: UIImageView!
    @IBOutlet weak var lblBalance: UILabel!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var btnAvatar: UIButton!

    @IBOutlet weak var swiAccountNotifications: UISwitch!
    @IBOutlet weak var swiPromoEmails: UISwitch!
    @IBOutlet weak var swiPromoNotifications: UISwitch!

    @IBOutlet weak var aiAccountNotifications: UIActivityIndicatorView!
    @IBOutlet weak var aiPromoEmails: UIActivityIndicatorView!
    @IBOutlet weak var aiPromoNotifications: UIActivityIndicatorView!

    @IBOutlet weak var vFloatingButtonContainer: UIView!
    @IBOutlet weak var lblFloatingButtonTitle: UILabel!
    @IBOutlet weak var ivFloatingButtonIcon: UIImageView!

    @IBOutlet weak var vEmailVerificationStatus: UIView!
    @IBOutlet weak var aiEmailVerificationStatus: UIActivityIndicatorView!

    @IBOutlet weak var vSMSVerificationStatus: UIView!
    @IBOutlet weak var aiSMSVerificationStatus: UIActivityIndicatorView!

    @IBOutlet weak var vIdentityVerificationStatus: UIView!
    @IBOutlet weak var aiIdentityVerificationStatus: UIActivityIndicatorView!

    @IBOutlet weak var aiLoadingWallet: UIActivityIndicatorView!

    @IBOutlet weak var lcBottomPadding: NSLayoutConstraint!

    @IBOutlet weak var btnVersion: UIButton!
    @IBOutlet weak var btnBuild: UIButton!

    @IBOutlet weak var lblVersion: UILabel!
    @IBOutlet weak var lblBuild: UILabel!

    @IBOutlet weak var lblMyAccount: UILabel!
    @IBOutlet weak var btnEditProfile: UIButton!
    @IBOutlet weak var btnChangeUsername: UIButton!
    @IBOutlet weak var btnChangePassword: UIButton!
    @IBOutlet weak var btnMyPaymentMethods: UIButton!
    @IBOutlet weak var btnHistory: UIButton!

    @IBOutlet weak var btnSupport: UIButton!

    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var lblSecurity: UILabel!
    @IBOutlet weak var btnVerifyEmail: UIButton!
    @IBOutlet weak var btnVerifyPhone: UIButton!
    @IBOutlet weak var btnVerifyIdentity: UIButton!
    @IBOutlet weak var lblInformation: UILabel!
    @IBOutlet weak var btnTerms: UIButton!
    @IBOutlet weak var btnPolicy: UIButton!
    @IBOutlet weak var btnLegal: UIButton!
    @IBOutlet weak var btnEticalCode: UIButton!
    @IBOutlet weak var btnOpenSource: UIButton!
    @IBOutlet weak var btnImpact: UIButton!
    @IBOutlet weak var btnProfilePinely: UIButton!
    @IBOutlet weak var btnVersionPremium: UIButton!
//    @IBOutlet weak var btnInstalledVersion: UIButton!

    @IBOutlet weak var btnCompilation: UIButton!

    @IBOutlet weak var btnBuyAmount: UIButton!
    @IBOutlet weak var btnAccountCreation: UIButton!
    @IBOutlet weak var btnLastLogin: UIButton!

    @IBOutlet weak var lblBuyAmount: UILabel!
    @IBOutlet weak var lblAccountCreation: UILabel!
    @IBOutlet weak var lblLastLogin: UILabel!

    @IBOutlet weak var aiBuyAmount: UIActivityIndicatorView!
    @IBOutlet weak var aiAccountCreation: UIActivityIndicatorView!
    @IBOutlet weak var aiLastLogin: UIActivityIndicatorView!

    @IBOutlet weak var lblNotification: UILabel!
    @IBOutlet weak var lblNotificationAboutAccount: UILabel!
    @IBOutlet weak var lblNotificationEmail: UILabel!
    @IBOutlet weak var lblNotificationPromo: UILabel!

    var verificationAvailable = false
    var emailVerificationAvailable = false

    var identityVerificationAvailable = false
    var identityVerificationStatus = ""

    var userRange = "client"

    var longPress1: UILongPressGestureRecognizer!
    var longPress2: UILongPressGestureRecognizer!

    var profile: Profile?

    override func viewDidLoad() {
        super.viewDidLoad()

        showUser()

        SwiftEventBus.onMainThread(self, name: "profileChanged") { (_) in
            self.showUser()
        }

        longPress1 = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        longPress1.minimumPressDuration = 0.5
        btnAvatar.addGestureRecognizer(longPress1)

        longPress2 = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        longPress2.minimumPressDuration = 0.5
        lblUsername.addGestureRecognizer(longPress2)

        lblUsername.isUserInteractionEnabled = true

        if let translation = AppDelegate.translation {
            btnVersion.setTitleFromTranslation("profile_version_installed", translation)
            btnBuild.setTitleFromTranslation("profile_compilation_installed", translation)

            btnBuyAmount.setTitleFromTranslation("profile_purchases", translation)
            btnAccountCreation.setTitleFromTranslation("profile_creation_account", translation)
            btnLastLogin.setTitleFromTranslation("profile_last_login", translation)

            btnEditProfile.setTitleFromTranslation("profile_edit_profile", translation)
            btnChangeUsername.setTitleFromTranslation("profile_change_username", translation)
            btnChangePassword.setTitleFromTranslation("profile_change_password", translation)
            btnMyPaymentMethods.setTitleFromTranslation("profile_payment_methods", translation)
            btnHistory.setTitleFromTranslation("profile_shopping_history", translation)
            btnSupport.setTitleFromTranslation("profile_support", translation)
            btnLogout.setTitleFromTranslation("profile_logout", translation)

            btnVerifyEmail.setTitleFromTranslation("profile_email_verification", translation)
            btnVerifyPhone.setTitleFromTranslation("profile_mobile_verification", translation)
            btnVerifyIdentity.setTitleFromTranslation("profile_id_verification", translation)
            btnTerms.setTitleFromTranslation("profile_terms_conditions", translation)
            btnPolicy.setTitleFromTranslation("profile_privacy_policie", translation)
            btnLegal.setTitleFromTranslation("profile_legal_advice", translation)

            btnEticalCode.setTitleFromTranslation("profile_etical", translation)
            btnOpenSource.setTitleFromTranslation("profile_open_source", translation)
            btnImpact.setTitleFromTranslation("profile_environmental_impact", translation)

            btnProfilePinely.setTitleFromTranslation("profile_pinely_1", translation)
            btnVersionPremium.setTitleFromTranslation("pinely_profile_premium", translation)

            lblMyAccount.text = translation.getString("profile_my_account") ?? lblMyAccount.text

            lblSecurity.text = translation.getString("profile_security") ?? lblSecurity.text

            lblInformation.text = translation.getString("profile_information") ?? lblInformation.text

            lblNotification.text = translation.getString("profile_notifications") ?? lblNotification.text
            lblNotificationAboutAccount.text = translation.getString("profile_notifications_about_my_account") ?? lblNotificationAboutAccount.text
            lblNotificationEmail.text = translation.getString("profile_notifications_email_promo") ?? lblNotificationEmail.text
            lblNotificationPromo.text = translation.getString("profile_notifications_promo") ?? lblNotificationPromo.text
        }

        lblVersion.text = Bundle.mainAppVersion ?? "Unknown"
        lblBuild.text = Bundle.mainAppBuild ?? "Unknown"

        swiPromoEmails.transform = CGAffineTransform(scaleX: 0.6, y: 0.6).translatedBy(x: 16, y: 0)
        swiPromoNotifications.transform = CGAffineTransform(scaleX: 0.6, y: 0.6).translatedBy(x: 16, y: 0)
        swiAccountNotifications.transform = CGAffineTransform(scaleX: 0.6, y: 0.6).translatedBy(x: 16, y: 0)
    }

    func checkMobileVerification() {
        API.shared.checkMobileVerification { (verificationStatus, _) in
            self.aiSMSVerificationStatus.stopAnimating()

            if verificationStatus == "verified" {
                self.vSMSVerificationStatus.backgroundColor = UIColor(hex: 0x00E836)!
                self.verificationAvailable = false
            } else {
                self.vSMSVerificationStatus.backgroundColor = UIColor(hex: 0xFF0000)!
                self.verificationAvailable = true
            }
            self.vSMSVerificationStatus.isHidden = false
        }
    }

    fileprivate func showUsername() {
        if let username = profile?.username,
           !username.isEmpty {
            self.lblUsername.text = username
        } else {
            self.lblUsername.text = Auth.auth().currentUser?.displayName ?? "Name not set"
        }
    }

    fileprivate func applyAndShowRange() {
        let rangeSafe = profile?.range ?? "client"
        self.userRange = rangeSafe

        if rangeSafe == "staff" {
            self.lblFloatingButtonTitle.text = "Gestionar mis salas"
            self.ivFloatingButtonIcon.image = #imageLiteral(resourceName: "IconBusiness")
            self.vFloatingButtonContainer.isHidden = false
            self.lcBottomPadding.constant = 100
        } else if rangeSafe == "reader" {
            self.lblFloatingButtonTitle.text = AppDelegate.translation?.getString("reader_button_text") ?? "Escanear entradas"
            self.ivFloatingButtonIcon.image = #imageLiteral(resourceName: "IconQR")
            self.vFloatingButtonContainer.isHidden = false
            self.lcBottomPadding.constant = 100
        } else {
            self.vFloatingButtonContainer.isHidden = true
            self.lcBottomPadding.constant = 30
        }
    }

    fileprivate func showVerificationStatus() {
        self.aiSMSVerificationStatus.stopAnimating()
        let verificationStatus = profile?.smsVerification
        if verificationStatus == "verified" {
            self.vSMSVerificationStatus.backgroundColor = UIColor(hex: 0x00E836)!
            self.verificationAvailable = false
        } else {
            self.vSMSVerificationStatus.backgroundColor = UIColor(hex: 0xFF0000)!
            self.verificationAvailable = true
        }
        self.vSMSVerificationStatus.isHidden = false
    }

    func checkIdentityVerification() {
        self.aiIdentityVerificationStatus.stopAnimating()

        self.identityVerificationStatus = profile?.dniVerification ?? ""
        switch self.identityVerificationStatus {
        case "completed":
            self.vIdentityVerificationStatus.backgroundColor = UIColor(hex: 0x00E836)!
            self.identityVerificationAvailable = false

        case "in_review":
            self.vIdentityVerificationStatus.backgroundColor = UIColor(hex: 0xFFA000)!
            self.identityVerificationAvailable = false

        default:
            self.vIdentityVerificationStatus.backgroundColor = UIColor(hex: 0xFF0000)!
            self.identityVerificationAvailable = true
        }
        self.vIdentityVerificationStatus.isHidden = false

        self.aiBuyAmount.stopAnimating()
        self.aiLastLogin.stopAnimating()
        self.aiAccountCreation.stopAnimating()

        self.lblBuyAmount.isHidden = false
        self.lblLastLogin.isHidden = false
        self.lblAccountCreation.isHidden = false

        self.lblBuyAmount.text = profile?.profilePurchases
        self.lblLastLogin.text = profile?.getLastLoginDate()
        self.lblAccountCreation.text = profile?.getDateByTimeZone()

        self.showUsername()
        self.applyAndShowRange()

        self.view.layoutIfNeeded()

        self.showVerificationStatus()
    }

    deinit {
        SwiftEventBus.unregister(self)
    }

    @objc func longPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            ivProfilePictureShadow.clickEnded()
            ivProfilePicture.clickEnded()

            let alert = UIAlertController(title: "Ajustes rápidos de tu cuenta", message: "¿Qué quieres hacer?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Cambiar avatar", style: .default) { (_) in
                self.selectPhotoFromGallery(croppingStyle: .circular)
            })
            alert.addAction(UIAlertAction(title: "Cambiar usuario", style: .default) { (_) in
            self.performSegue(withIdentifier: "ChangeNickname", sender: self)
            })

            alert.addAction(UIAlertAction(title: "Editar mi perfil", style: .default) { (_) in
            self.performSegue(withIdentifier: "EditProfile", sender: self)

            })
            alert.addAction(UIAlertAction(title: "Cerrar sesión", style: .destructive) { (_) in
                self.logOut()
            })
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = self.ivProfilePicture
            }
            self.present(alert, animated: true, completion: nil)
        }
    }

    func showUser() {
        Auth.auth().currentUser?.reload(completion: { [weak self] _ in
            self?.aiEmailVerificationStatus.stopAnimating()
            self?.vEmailVerificationStatus.isHidden = false
            if Auth.auth().currentUser?.isEmailVerified == true {
                self?.vEmailVerificationStatus.backgroundColor = UIColor(hex: 0x00E836)!
                self?.emailVerificationAvailable = false
            } else {
                self?.vEmailVerificationStatus.backgroundColor = UIColor(hex: 0xFF0000)!
                self?.emailVerificationAvailable = true
            }
        })

        API.shared.getWalletAmount { (amount, _) in
            self.aiLoadingWallet.stopAnimating()
            self.lblBalance.text = amount?.toString() ?? ""
        }

        API.shared.loadUserInfo(force: true) { (profile, _) in
            self.profile = profile

            self.aiAccountNotifications.stopAnimating()
            self.aiPromoEmails.stopAnimating()
            self.aiPromoNotifications.stopAnimating()

            self.swiAccountNotifications.isHidden = false
            self.swiPromoNotifications.isHidden = false
            self.swiPromoEmails.isHidden = false

            self.swiAccountNotifications.isOn = profile?.pushNotifications == "enabled"
            self.swiPromoNotifications.isOn = profile?.pushPromoNotifications == "enabled"
            self.swiPromoEmails.isOn = profile?.emailsNotifications == "enabled"

            self.showUsername()
            self.applyAndShowRange()

            self.view.layoutIfNeeded()

            self.showVerificationStatus()

            self.checkIdentityVerification()
        }

        if let photoUrl = Auth.auth().currentUser?.photoURL {
            ivProfilePicture.backgroundColor = .clear
            ivProfilePicture.kf.setImage(with: photoUrl)
        } else {
            ivProfilePicture.image = #imageLiteral(resourceName: "AvatarPinely")
        }
    }

    @IBAction func changeUsername() {
        performSegue(withIdentifier: "ChangeNickname", sender: self)
    }

    @IBAction func editProfile() {
        performSegue(withIdentifier: "EditProfile", sender: self)
    }

    @IBAction func resetPassword() {
        guard let user = Auth.auth().currentUser,
              let email = user.email
        else {
            return
        }

        let translation = AppDelegate.translation
        let title = translation?.getString("change_password_popup_title") ?? "changePassword".localized
        let message = (translation?.getString("change_password_popup_description") ??
                       "willSendEmailToChangePassword".localized)
            .replacingOccurrences(of: "$email", with: email)
        let send = translation?.getString("change_password_popup_button_send") ?? "Enviar"
        let cancel = translation?.getString("change_password_popup_button_back") ?? "Cancelar"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: send, style: .default) { (_) in
            let loading = BlurryLoadingView.showAndStart()
            Auth.auth().sendPasswordReset(withEmail: email) { (error) in
                loading.stopAndHide()
                if let error = error {
                    self.show(error: error)
                    return
                }
            }
        })
        alert.addAction(UIAlertAction(title: cancel, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    @IBAction func termsConditions() {
        showWeb(title: btnTerms.title(for: .normal) ?? "",
                pageLink: .termsAndConditions)
    }

    @IBAction func privacyPolicy() {
        showWeb(title: btnPolicy.title(for: .normal) ?? "",
                pageLink: .privacyPolicy)
    }

    @IBAction func legal() {
        showWeb(title: btnLegal.title(for: .normal) ?? "",
                pageLink: .advise)
    }

    @IBAction func eticalCode() {
        showWeb(title: btnEticalCode.title(for: .normal) ?? "",
                pageLink: .eticalCode)
    }

    @IBAction func environmentImpact() {
        showWeb(title: btnImpact.title(for: .normal) ?? "",
                pageLink: .environmentImpact)
    }

    @IBAction func support() {
        let blurryLoading = BlurryLoadingView.showAndStart()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        appDelegate?.remoteConfig.configSettings = settings
        appDelegate?.remoteConfig.fetchAndActivate { (_, _) -> Void in
            blurryLoading.stopAndHide()
            self.performSegue(withIdentifier: "Support", sender: self)
        }
    }

    @IBAction func startEmailVerification() {
        if emailVerificationAvailable {
            verifyFirebaseUserEmail()
        }
    }

    @IBAction func startMobileVerification() {
        if emailVerificationAvailable {
            verifyFirebaseUserEmail()
        } else if verificationAvailable {
            verifyMobileNumber()
        }
    }

    @IBAction func startIdentityVerification() {
        if identityVerificationAvailable {
            if let translation = AppDelegate.translation {
                let alert = UIAlertController(
                    title: translation.getString("profile_id_verification_pop_up_title"),
                    message: translation.getString("profile_id_verification_pop_up_description"),
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(
                    title: translation.getString("profile_id_verification_pop_up_button"),
                    style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        } else if identityVerificationStatus == "completed" {
            let alert = UIAlertController(
                title: "alert.excellent".localized,
                message: "alert.idNeedsVerification".localized,
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "button.back".localized, style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        } else if identityVerificationStatus == "in_review" {
            let alert = UIAlertController(title: "alert.ops".localized,
                                          message: "alert.documentInRevision".localized,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "button.back".localized, style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func openProfilePinely() {

    }

    @IBAction func premiumVersion() {

    }

    @IBAction func logOut() {
        let translation = AppDelegate.translation
        let title = translation?.getString("popup_close_session_title") ?? "One moment!"
        let message = translation?.getString("popup_close_session_description") ?? "You will have to log in again to return to this account"
        let logout = translation?.getString("popup_close_session_agreebutton") ?? "Log out"
        let cancel = translation?.getString("popup_close_session_backbutton") ?? "Cancel"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: logout, style: .destructive) { (_) in
            Profile.current = nil
            Profile.userToken = nil

            _ = try? Auth.auth().signOut()

            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            if let initialVC = mainStoryboard.instantiateInitialViewController(),
                let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                let window = appDelegate.window {
                window.rootViewController = initialVC
                window.makeKeyAndVisible()
            }
        })
        alert.addAction(UIAlertAction(title: cancel, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        AppSound.logOut.play()
    }

    @IBAction func showTickets() {
        UIDevice.vibrate()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            switch self.userRange {
            case "reader":
                let readerStoryboard = UIStoryboard(name: "Reader", bundle: nil)
                let initialVC = readerStoryboard.instantiateInitialViewController()!
                if let initialNC = initialVC as? UINavigationController {
                    let firstVC = initialNC.viewControllers[0]
                    self.navigationController?.pushViewController(firstVC, animated: true)
                } else {
                    self.navigationController?.pushViewController(initialVC, animated: true)
                }

            case "staff":
                let staffStoryboard = UIStoryboard(name: "Staff", bundle: nil)
                let initialVC = staffStoryboard.instantiateInitialViewController()!
                if let initialNC = initialVC as? UINavigationController {
                    let firstVC = initialNC.viewControllers[0]
                    self.navigationController?.pushViewController(firstVC, animated: true)
                } else {
                    self.navigationController?.pushViewController(initialVC, animated: true)
                }

            default:
                break
            }
        }
    }

    @IBAction func changeProfilePicture() {
        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let alert = UIAlertController(title: "alert.changeAvatar".localized,
                                          message: "alert.selectAvatarPhoto".localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "button.select".localized, style: .default) { (_) in
                self.selectPhotoFromGallery(croppingStyle: .circular)
            })
            alert.addAction(UIAlertAction(title: "button.cancel".localized, style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func balance() {
        let alert: UIAlertController

        if let translation = AppDelegate.translation {
            alert = UIAlertController(
                title: translation.getString("wallet_title") ?? "alert.wallet".localized,
                message: translation.getString("wallet_description") ?? "alert.walletDescription".localized,
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(
                title: translation.getString("wallet_agree_button") ?? "button.accept".localized,
                style: .default) { (_) in })
        } else {
            alert = UIAlertController(title: "alert.wallet".localized,
                                      message: "alert.walletDescription".localized,
                                      preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "button.accept".localized, style: .default) { (_) in

            })

        }
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func openSourceAndMentions(_ sender: Any) {
        showWeb(title: btnOpenSource.title(for: .normal) ?? "",
                pageLink: .openSource)
    }

    @IBAction func installedVersions(_ sender: Any) {
        let version = Bundle.mainAppVersion ?? "Unknown"
        let message = "\(version)"
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "button.accept".localized, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let changeNicknameVC = segue.destination as? ChangeNicknameViewController {
            changeNicknameVC.oldNickname = self.lblUsername.text ?? ""
        } else if let mobileVerificationVC = segue.destination as? MobileVerificationViewController {
            mobileVerificationVC.ipInfo = sender as? IpInfo
        } else if let editProfileVC = segue.destination as? EditProfileViewController {
            editProfileVC.profile = profile
        }
    }

    override func photoSelected(image: UIImage?) {
        guard let image = image,
            let user = Auth.auth().currentUser
            else { return }

        self.ivProfilePicture.backgroundColor = .clear
        self.ivProfilePicture.image = image

        if let imageToUpload = image.resized(maxSize: 150),
           let uploadData = imageToUpload.jpegData(compressionQuality: 0.9) {

            let storageKey = "users/\(user.uid)/avatar.jpg"
            let storageRef = Storage.storage().reference().child(storageKey)
            storageRef.putData(uploadData, metadata: nil) { [weak self] (_, error) in
                if let error = error {
                    self?.show(error: error)
                    return
                }

                storageRef.downloadURL { [weak self] (url, error) in
                    if let error = error {
                        self?.show(error: error)
                        return
                    }

                    let request = user.createProfileChangeRequest()
                    request.photoURL = url
                    request.commitChanges { [weak self] (error) in
                        if let error = error {
                            self?.show(error: error)
                        }

                        SwiftEventBus.post("profilePictureChanged")
                    }
                }
            }
        }
    }

    @IBAction func switchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            AppSound.toggleOn.play()
        } else {
            AppSound.toggleOff.play()
        }
        UIDevice.vibrate()

        let type: String
        switch sender {
        case swiPromoEmails: type = "emails"
        case swiPromoNotifications: type = "push_promo"
        case swiAccountNotifications: type = "push"
        default: return
        }

        API.shared.updateNotificationSettings(type: type, isEnabled: sender.isOn)
    }
}
