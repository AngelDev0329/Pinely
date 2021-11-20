//
//  Registrator.swift
//  Pinely
//

import Foundation
import FirebaseAuth
import SwiftEventBus

class Registrator {
    static func hasUnfinishedRegistration() -> Bool {
        !(UserDefaults.standard.string(forKey: "registration.email") ?? "").isEmpty
    }

    private static func performNewRegistration(
        _ email: String, _ password: String, _ loadingView: LoadingView?,
        _ viewController: ViewController, _ delegate: @escaping () -> Void) {
        // Make registration from scratch
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if result?.user == nil {
                Auth.auth().createUser(withEmail: email, password: password) { (_, error) in
                    if let error = error?.asAFError,
                       error.responseCode == 17007 {
                        self.registrationEnded()
                        loadingView?.stopAndRemove()
                        viewController.showError("error.emailIsOccupied".localized
                                                    .replacingOccurrences(of: "$email", with: email))
                        return
                    } else if let error = error {
                        Registrator.registrationEnded()
                        loadingView?.stopAndRemove()
                        if error.localizedDescription.contains("email address is already in use") {
                            viewController.showError("error.emailIsOccupied".localized
                                                        .replacingOccurrences(of: "$email", with: email))
                        } else {
                            viewController.show(error: error)
                        }
                        return
                    }

                    // Now we're logged in, go using another scenario
                    Registrator.finishRegistration(viewController: viewController, usingLoadingView: loadingView, delegate: delegate)
                }
            } else {
                // Now we're logged in, go using another scenario
                Registrator.finishRegistration(viewController: viewController, usingLoadingView: loadingView, delegate: delegate)
            }
        }
    }

    private static func finishExistingRegistration(
        _ isSocial: Bool, _ firstName: String, _ lastName: String, _ email: String,
        _ phone: String, _ dobDate: Date, _ loadingView: LoadingView?, _ viewController: ViewController,
        _ user: User) {
        // Finish existing registration
        API.shared.getUserToken { (_, _) in
            if isSocial {
                // Register in API
                API.shared.registerUser(firstName: firstName, lastName: lastName,
                                        email: email, mobilePhone: phone, dateOfBirth: dobDate) { (error) in
                    Registrator.registrationEnded()
                    if let error = error {
                        loadingView?.stopAndRemove()
                        viewController.show(error: error)
                        return
                    }

                    SwiftEventBus.post("authChanged")
                    loadingView?.stopAndRemove()
                }
            } else {
                let request = user.createProfileChangeRequest()
                request.displayName = "\(firstName) \(lastName)"
                request.commitChanges { (_) in
                    // Register in API
                    API.shared.registerUser(firstName: firstName, lastName: lastName,
                                            email: email, mobilePhone: phone, dateOfBirth: dobDate) { (error) in
                        Registrator.registrationEnded()
                        if let error = error {
                            loadingView?.stopAndRemove()
                            viewController.show(error: error)
                            return
                        }

                        SwiftEventBus.post("authChanged")
                        loadingView?.stopAndRemove()
                    }
                }
            }
        }
    }

    private static func cancelRegistration(_ loadingView: LoadingView?) {
        // Can't do much. User needs to register again
        Registrator.registrationEnded()
        loadingView?.stopAndRemove()
        _ = try? Auth.auth().signOut()
        SwiftEventBus.post("authChanged")
    }

    static func finishRegistration(viewController: ViewController,
                                   usingLoadingView: LoadingView? = nil,
                                   delegate: @escaping () -> Void = {
        // Default empty delegate
    }) {
        let userDefaults = UserDefaults.standard

        guard let firstName = userDefaults.string(forKey: StorageKey.registrationFirstName.rawValue),
            let lastName = userDefaults.string(forKey: StorageKey.registrationLastName.rawValue),
            let email = userDefaults.string(forKey: StorageKey.registrationEmail.rawValue),
            let phone = userDefaults.string(forKey: StorageKey.registrationPhone.rawValue)
        else {
            Registrator.registrationEnded()
            _ = try? Auth.auth().signOut()
            SwiftEventBus.post("authChanged")
            delegate()
            return
        }

        let loadingView = usingLoadingView ?? LoadingView.showAndRun(
            text: "loading.creatingAccount".localized, viewController: viewController)

        let isSocial = userDefaults.bool(forKey: StorageKey.registrationIsSocial.rawValue)
        let dateOfBirth = userDefaults.double(forKey: StorageKey.registrationDOB.rawValue)
        let dobDate = Date(timeIntervalSince1970: dateOfBirth)

        let fireUser = Auth.auth().currentUser
        if fireUser == nil && !isSocial, let password = userDefaults.string(forKey: StorageKey.registrationPassword.rawValue) {
            performNewRegistration(email, password, loadingView, viewController, delegate)
        } else if let user = fireUser {
            finishExistingRegistration(isSocial, firstName, lastName, email, phone, dobDate, loadingView, viewController, user)
        } else {
            cancelRegistration(loadingView)
        }
    }

    private static func registrationEnded() {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: StorageKey.registrationFirstName.rawValue)
        userDefaults.removeObject(forKey: StorageKey.registrationLastName.rawValue)
        userDefaults.removeObject(forKey: StorageKey.registrationEmail.rawValue)
        userDefaults.removeObject(forKey: StorageKey.registrationPhone.rawValue)
        userDefaults.removeObject(forKey: StorageKey.registrationIsSocial.rawValue)
        userDefaults.removeObject(forKey: StorageKey.registrationDOB.rawValue)
        userDefaults.removeObject(forKey: StorageKey.registrationPassword.rawValue)
    }
}
