//
//  LoginViewController+apple.swift
//  Pinely
//

import UIKit
import FirebaseAuth
import SwiftEventBus
import FirebaseAnalytics
import AuthenticationServices

@available(iOS 13.0, *)
extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        self.view.window!
    }
}

@available(iOS 13.0, *)
extension LoginViewController: ASAuthorizationControllerDelegate {
    private func createNewAppleUser(authResult: AuthDataResult,
                                    appleIDCredential: ASAuthorizationAppleIDCredential,
                                    loadingView: BlurryLoadingView) {
        let lastName = appleIDCredential.fullName?.familyName ?? ""
        let firstName = appleIDCredential.fullName?.givenName ?? ""
        let email = authResult.user.email ?? appleIDCredential.email ?? ""
        API.shared.registerUser(firstName: firstName, lastName: lastName,
                                email: email, mobilePhone: nil,
                                dateOfBirth: nil) { (error) in
            loadingView.stopAndHide()
            if let error = error {
                self.show(error: error)
                return
            }

            Analytics.logEvent(AnalyticsEventSignUp, parameters: [
                AnalyticsParameterMethod: "Apple"
            ])

            SwiftEventBus.post("authChanged")
            self.dismiss(animated: true, completion: nil)
        }
    }

    private func appleUserAuthenticated(
        authResult: AuthDataResult, loadingView: BlurryLoadingView,
        appleIDCredential: ASAuthorizationAppleIDCredential) {
        // User is signed in to Firebase with Google
        API.shared.checkUser(uid: authResult.user.uid) { (exists, error) in
            if let error = error {
                self.signInFailedWithError(error, loadingView: loadingView)
                return
            }

            API.shared.getUserToken { (_, _) in
                self.notificationFeedbackGenerator.notificationOccurred(.success)
                if exists {
                    self.loginEndedWithSuccess(method: "Apple", loadingView: loadingView)
                } else {
                    self.createNewAppleUser(authResult: authResult,
                                            appleIDCredential: appleIDCredential,
                                            loadingView: loadingView)
                }
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            // Sign in with Firebase.
            let loading = BlurryLoadingView.showAndStart()
            self.notificationFeedbackGenerator.prepare()
            Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
                if let error = error {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    loading.stopAndHide()
                    print(error.localizedDescription)
                } else if let authResult = authResult {
                    self?.appleUserAuthenticated(authResult: authResult, loadingView: loading,
                                                 appleIDCredential: appleIDCredential)
                } else {
                    loading.stopAndHide()
                }
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
}
