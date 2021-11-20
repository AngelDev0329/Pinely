//
//  LoginViewController.swift
//  Pinely
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import SwiftEventBus
import AuthenticationServices

class LoginViewController: ViewController {
    @IBOutlet weak var lblTermsAndPrivacy: UILabel!

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!

    @IBOutlet weak var lblButtonApple: UILabel!
    @IBOutlet weak var lblButtonGoogle: UILabel!
    @IBOutlet weak var lblButtonPinely: UILabel!

    var currentNonce: String?

    let notificationFeedbackGenerator = UINotificationFeedbackGenerator()

    override func viewDidLoad() {
        super.viewDidLoad()

        lblTermsAndPrivacy.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapLabel(gesture:))))

        if let translation = AppDelegate.translation {
            lblTitle.text = translation.getString("login_title") ?? lblTitle.text
            lblSubTitle.text = translation.getString("login_description") ?? lblSubTitle.text
            lblButtonApple.text = translation.getString("apple_button_login") ?? lblButtonApple.text
            lblButtonGoogle.text = translation.getString("google_button_login") ?? lblButtonGoogle.text
            lblButtonPinely.text = translation.getString("pinely_button_login") ?? lblButtonPinely.text
        }
    }

    @objc func tapLabel(gesture: UITapGestureRecognizer) {
        let text = (lblTermsAndPrivacy.attributedText?.string ?? "") as NSString
        let termsRange = text.range(of: "Términos y Condiciones")
        let privacyRange = text.range(of: "Política de Privacidad")

        if gesture.didTapAttributedTextInLabel(label: lblTermsAndPrivacy, inRange: termsRange) {
            print("Tapped Términos y Condiciones")
            openEula()
        } else if gesture.didTapAttributedTextInLabel(label: lblTermsAndPrivacy, inRange: privacyRange) {
            print("Política de Privacidad")
            openPrivacy()
        } else {
            print("Tapped none")
        }
    }

    private func openEula() {
        if let url = PageLink.termsAndConditions.getUrl() {
            self.performSegue(withIdentifier: "Accept",
                              sender: ("Términos y Condiciones", url))
        }
    }

    private func openPrivacy() {
        if let url = PageLink.privacyPolicy.getUrl() {
            self.performSegue(withIdentifier: "Accept",
                              sender: ("Política de privacidad", url))
        }
    }

    @IBAction func continueWithApple() {
        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if #available(iOS 13, *) {
                self.startSignInWithAppleFlow()
            } else {
                self.showError("Apple sign in is not available on your device. Please update to iOS 13 or newer.")
            }
        }
    }

    func sha256(_ data: Data) -> Data? {
        guard let result = NSMutableData(length: Int(CC_SHA256_DIGEST_LENGTH)) else { return nil }
        CC_SHA256((data as NSData).bytes, CC_LONG(data.count), result.mutableBytes.assumingMemoryBound(to: UInt8.self))
        return result as Data
    }

    private func sha256(_ input: String) -> String {
        guard
            let data = input.data(using: String.Encoding.utf8),
            let shaData = sha256(data)
            else { return input }
        let hashString = shaData.compactMap {
            return String(format: "%02x", $0)
        }.joined()

        return hashString
    }

    @available(iOS 13, *)
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: [Character] =
          Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
          }
          return random
        }

        randoms.forEach { random in
          if length == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }

    @IBAction func continueWithGoogle() {
        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let clientID = FirebaseApp.app()!.options.clientID!
            let signInConfig = GIDConfiguration.init(clientID: clientID)
            GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
                if let user = user {
                    self.sign(GIDSignIn.sharedInstance, didSignInFor: user, withError: error)
                } else if let error = error {
                    self.sign(GIDSignIn.sharedInstance, didDisconnectWith: nil, withError: error)
                }
            }
        }
    }

    @IBAction func continueWithPinely() {
        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.performSegue(withIdentifier: "PinelyLogin", sender: self)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let acceptVC = segue.destination as? AcceptViewController,
            let args = sender as? (String, URL) {
            acceptVC.pageTitle = args.0
            acceptVC.pageUrl = args.1
        }
    }

    func signInFailedWithError(_ error: Error, loadingView: BlurryLoadingView) {
        loadingView.stopAndHide()
        _ = try? Auth.auth().signOut()
        self.show(error: error)
    }
}
