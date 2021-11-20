//
//  ViewController.swift
//  Pinely
//
//  Created by Francisco de Asis Jimenez Tirado on 20/06/2020.
//  Copyright © 2020 Francisco de Asis Jimenez Tirado. All rights reserved.
//

import UIKit
import Gallery
import CropViewController
import AFWebViewController
import FirebaseAuth
import FirebaseAnalytics
import FirebaseDynamicLinks
import SwiftEventBus
import Mixpanel

class ViewController: UIViewController {
    var galleryNavigator: UINavigationController?
    var croppingStyle: CropViewCroppingStyle?
    var loadingViewShowing = false

    // Search bar is present
    @IBOutlet weak var ivSearchIcon: UIImageView?
    @IBOutlet weak var ivSearchIcon1: UIImageView?
    @IBOutlet weak var ivSearchIcon2: UIImageView?
    @IBOutlet weak var lblSearch: UILabel?
    @IBOutlet weak var tfSearch: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()

        DarkMode.activate(viewController: self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let navigationController = self.navigationController,
           navigationController.viewControllers.count <= 1 {
            navigationController.interactivePopGestureRecognizer?.isEnabled = false
        } else {
            navigationController?.interactivePopGestureRecognizer?.delegate = nil
            navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        view.endEditing(true)

        super.viewWillDisappear(animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        view.updateAllShadows()
    }

    func open(url: String, title: String? = nil) {
        let webVC = AFModalWebViewController(address: url)
        if let title = title {
            webVC.title = title
        }
//        webVC.barsTintColor = UIColor(hex: 0xE08E26)!
//        webVC.toolbarTintColor = UIColor(hex: 0xD55A30)! // iOS only
        present(webVC, animated: true, completion: nil)
    }

    func takePhotoFromCamera(croppingStyle: CropViewCroppingStyle?) {
        self.croppingStyle = croppingStyle

        Config.tabsToShow = [ .cameraTab ]
        Config.initialTab = Config.GalleryTab.cameraTab
        Config.Camera.imageLimit = 1
        Config.Camera.singleImageMode = true
        Config.Permission.Button.backgroundColor = .black

        let gallery = GalleryController()
        gallery.delegate = self

        self.galleryNavigator = UINavigationController(rootViewController: gallery)
        self.galleryNavigator!.isNavigationBarHidden = true
        self.present(self.galleryNavigator!, animated: true, completion: nil)
    }

    func selectPhotoFromGallery(croppingStyle: CropViewCroppingStyle?) {
        self.croppingStyle = croppingStyle

        Config.tabsToShow = [ .imageTab ]
        Config.initialTab = Config.GalleryTab.imageTab
        Config.Camera.imageLimit = 1
        Config.Camera.singleImageMode = true
        Config.Permission.Button.backgroundColor = .black

        let gallery = GalleryController()
        gallery.delegate = self

        self.galleryNavigator = UINavigationController(rootViewController: gallery)
        self.galleryNavigator!.isNavigationBarHidden = true
        self.present(self.galleryNavigator!, animated: true, completion: nil)
    }

    func photoSelected(image: UIImage?) {

    }

    func shareText(_ text: String, sourceView: UIView) {
        let activityViewController: UIActivityViewController = UIActivityViewController(
            activityItems: [text], applicationActivities: nil)

        // This lines is for the popover you need to show in iPad
        activityViewController.popoverPresentationController?.sourceView = sourceView

        // This line remove the arrow of the popover to show in iPad
        activityViewController.popoverPresentationController?.permittedArrowDirections = .any
        activityViewController.popoverPresentationController?.sourceRect = sourceView.frame

        present(activityViewController, animated: true, completion: nil)
    }

    func createShareText(stringId: String,
                         eventName: String?,
                         roomName: String?,
                         url: URL?) -> String {
        var text = stringId.localized
        if let eventName = eventName {
            text = text.replacingOccurrences(of: "$eventName", with: eventName)
        }
        if let roomName = roomName {
            text = text.replacingOccurrences(of: "$roomName", with: roomName)
        }
        if let url = url {
            text = text.replacingOccurrences(of: "$url", with: url.absoluteString)
        }
        return text
    }

    func generate(link: URL, title: String?, descriptionText: String?, imageURL: URL?, delegate: @escaping (_ url: URL) -> Void) {
        let dynamicLinksDomain = ShareLink.dynamicLinksDomain.urlString
        let loading = BlurryLoadingView.showAndStart()
        if let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: dynamicLinksDomain) {
            if title != nil || descriptionText != nil || imageURL != nil {
                let socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
                socialMetaTagParameters.title = title
                socialMetaTagParameters.descriptionText = descriptionText
                socialMetaTagParameters.imageURL = imageURL
                linkBuilder.socialMetaTagParameters = socialMetaTagParameters
            }

            let options = DynamicLinkComponentsOptions()
            options.pathLength = .short // .short = 4 digits

            linkBuilder.options = options
            linkBuilder.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.app.pinely")
            linkBuilder.iOSParameters?.appStoreID = "1524802936"
            linkBuilder.otherPlatformParameters = DynamicLinkOtherPlatformParameters()
            linkBuilder.otherPlatformParameters?.fallbackUrl = ShareLink.fallbackUrl.url
            linkBuilder.androidParameters = DynamicLinkAndroidParameters(packageName: "com.pinely.android")

            guard let longDynamicLink = linkBuilder.url else {
                loading.stopAndHide()
                delegate(link)
                return
            }

            linkBuilder.shorten { url, _, _ in
                loading.stopAndHide()
                delegate(url ?? longDynamicLink)
            }
        } else {
            loading.stopAndHide()
            delegate(link)
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if loadingViewShowing {
            return .lightContent
        } else {
            return preferredStatusBarStyleInternal
        }
    }

    var preferredStatusBarStyleInternal: UIStatusBarStyle {
        .default
    }

    func loadingViewStarted() {
        loadingViewShowing = true
        setNeedsStatusBarAppearanceUpdate()
    }

    func loadingViewFinished() {
        loadingViewShowing = false
        setNeedsStatusBarAppearanceUpdate()
    }

    func verifyFirebaseUserEmail() {
        var strTitle: String?
        var strDescription: String?
        var strSend: String?
        var strCancel: String?

        let email = Auth.auth().currentUser?.email ?? ""
        let translation = AppDelegate.translation
        strTitle = translation?.getString("profile_email_verification_pop_up_title") ?? "alert.verifyEmail".localized

        strDescription = translation?.getString("profile_email_verification_pop_up_description") ?? "alert.willSendEmail".localized

        strCancel = translation?.getString("profile_email_verification_button1") ?? "Cancelar"
        strSend = translation?.getString("profile_email_verification_button2") ?? "Enviar"

        strDescription = strDescription?.replacingOccurrences(of: "$email", with: email)

        let alert = UIAlertController(title: strTitle, message: strDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: strCancel, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: strSend, style: .default) { _ in
            let loading = BlurryLoadingView.showAndStart()
            Auth.auth().currentUser?.sendEmailVerification(completion: { error in
                loading.stopAndHide()
                if let error = error {
                    self.show(error: error)
                } else {
                    let alertCompleted = UIAlertController(title: "alert.verifyEmail".localized,
                                                           message: "alert.emailSent".localized,
                                                           preferredStyle: .alert)
                    alertCompleted.addAction(UIAlertAction(title: "button.accept".localized, style: .cancel, handler: nil))
                    self.present(alertCompleted, animated: true, completion: nil)
                }
            })
        })
        present(alert, animated: true, completion: nil)
    }

    func verifyMobileNumber() {
        let loading = BlurryLoadingView.showAndStart()
        API.shared.getIpInfo { (ipInfo, _) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let mobileVerificationVC =
                    storyboard.instantiateViewController(withIdentifier: "MobileVerification")
                    as? MobileVerificationViewController
            else {
                return
            }
            mobileVerificationVC.ipInfo = ipInfo
            loading.stopAndHide()
            if let navigationController = self.navigationController {
                navigationController.pushViewController(mobileVerificationVC, animated: true)
            } else {
                let navigationController = UINavigationController(rootViewController: mobileVerificationVC)
                self.present(navigationController, animated: true, completion: nil)
            }
        }
    }

    func showSearchBarPlaceholder() {
        ivSearchIcon?.isHidden = false
        ivSearchIcon1?.isHidden = false
        lblSearch?.isHidden = false
        ivSearchIcon2?.isHidden = true
    }

    func hideSearchBarPlaceholder() {
        ivSearchIcon?.isHidden = true
        ivSearchIcon1?.isHidden = true
        lblSearch?.isHidden = true
        ivSearchIcon2?.isHidden = false
    }

    func loginEndedWithSuccess(method: String, loadingView: BlurryLoadingView?) {
        loadingView?.stopAndHide()
        
//        let mixpanel = Mixpanel.initialize(token: "0b428098b8a412609c4cac444c6a723f", optOutTrackingByDefault: true)
        Mixpanel.mainInstance().track(event: "Login", properties: ["method" : method])
        
        Analytics.logEvent(AnalyticsEventLogin, parameters: [
            AnalyticsParameterMethod: method
        ])
        
        SwiftEventBus.post("authChanged")
        self.dismiss(animated: true, completion: nil)
    }
}
