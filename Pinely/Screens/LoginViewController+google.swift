//
//  LoginViewController+google.swift
//  Pinely
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import SwiftEventBus
import FirebaseAnalytics

// Google sign in
extension LoginViewController {
    private func createNewGoogleUser(authResult: AuthDataResult,
                                     loadingView: BlurryLoadingView,
                                     user: GIDGoogleUser?) {
        let lastName = user?.profile?.familyName ?? ""
        let firstName = user?.profile?.givenName ?? ""
        let email = authResult.user.email ?? user?.profile?.email ?? ""
        API.shared.registerUser(firstName: firstName, lastName: lastName,
                                email: email, mobilePhone: nil, dateOfBirth: nil) { (error) in
            loadingView.stopAndHide()
            if let error = error {
                self.show(error: error)
                return
            }

            Analytics.logEvent(AnalyticsEventSignUp, parameters: [
                AnalyticsParameterMethod: "Google"
            ])

            SwiftEventBus.post("authChanged")
            self.dismiss(animated: true, completion: nil)
        }
    }

    fileprivate func googleUserLoggedIn(
        authResult: AuthDataResult, loadingView: BlurryLoadingView, user: GIDGoogleUser?) {
        // User is signed in to Firebase with Google
        API.shared.checkUser(uid: authResult.user.uid) { (exists, error) in
            if let error = error {
                self.signInFailedWithError(error, loadingView: loadingView)
                return
            }

            API.shared.getUserToken { (_, _) in
                self.notificationFeedbackGenerator.notificationOccurred(.success)
                if exists {
                    self.loginEndedWithSuccess(method: "Google", loadingView: loadingView)
                } else {
                    self.createNewGoogleUser(authResult: authResult,
                                             loadingView: loadingView,
                                             user: user)
                }
            }
        }
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard let authentication = user?.authentication else {
            return
        }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken!,
                                                          accessToken: authentication.accessToken)

        let loading = BlurryLoadingView.showAndStart()
        self.notificationFeedbackGenerator.prepare()
        Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
            if let error = error {
                loading.stopAndHide()
                self?.show(error: error)
            } else if let authResult = authResult {
                self?.googleUserLoggedIn(authResult: authResult, loadingView: loading, user: user)
            } else {
                loading.stopAndHide()
            }
        }

    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Handle error.
        if let error = error {
            print("Sign in with Google errored: \(error)")
        }
    }
}
