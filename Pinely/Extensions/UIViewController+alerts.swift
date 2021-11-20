//
//  UIViewController+alerts.swift
//  Pinely
//

import UIKit

extension UIViewController {
    private func getLocalizedErrorMessage(_ message: String) -> String {
        if message.hasPrefix("Network error") {
            return "error.networkError".localized
        } else if message == "Event is not published" {
            return "error.eventNotFound".localized
        } else if message == "The password is invalid or the user does not have a password." {
            return "error.passwordInvalid".localized
        } else if message == "There is no user record corresponding to this identifier. The user may have been deleted." {
            return "error.noSuchUser".localized
        } else if message == "The email address is badly formatted." {
            return "error.badEmail".localized
        } else if message == "mobile_verified_in_another_account" {
            return "error.mobileInAnotherAccount".localized
        } else if message == "previously_verified" {
            return "error.previouslyVerified".localized
        } else if message == "Try after 5 minutes" {
            return "error.tryIn5Mins".localized
        } else if message == "mobile_not_valid" {
            return "error.mobileNotValid".localized
        } else if message == "User is banned" {
            return "error.userIsBanned".localized
        } else if message == "Invalid user status" {
            return "error.invalidUserStatus".localized
        } else {
            return message
        }
    }

    func showSuccess(
        _ message: String,
        delegate: @escaping () -> Void = {
            // Default empty delegate
        },
        title: String = "¡Sugerencia enviada!") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel) { (_) in
            delegate()
        })
        present(alert, animated: true, completion: nil)
    }

    func showSuccessCustom(
        title: String,
        message: String,
        button: String,
        delegate: @escaping () -> Void = {
            // Default empty delegate
        }) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: button, style: .cancel) { (_) in
            delegate()
        })
        present(alert, animated: true, completion: nil)
    }

    func showWarning(_ message: String, title: String = "Ups!") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func showWarningCustomButton(_ message: String, title: String = "Ups!", button: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: button, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func showErrorAndDismiss(
        error: Error,
        title: String = "Ups!"
    ) {
        show(error: error, delegate: { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }, title: title)
    }

    func show(error: Error,
              delegate: @escaping () -> Void = {
                  // Default empty delegate
              },
              title: String = "Ups!") {
        switch error {
        case NetworkError.serverError:
            let locMessage = "connection_failed".localized
            let alert = UIAlertController(title: title, message: locMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "button.ok".localized, style: .cancel) { (_) in
                delegate()
            })
            alert.addAction(UIAlertAction(title: "button.plusInfo".localized, style: .default) { (_) in
                if let url = URL(string: "https://status.pinely.app") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            })
            present(alert, animated: true, completion: nil)

        default:
            showError(error.localizedDescription, delegate: delegate, title: title)
        }
    }

    func showErrorAndDismiss(
        message: String,
        title: String = "Ups!"
    ) {
        showError(message, delegate: { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }, title: title)
    }

    func showError(
        _ message: String,
        delegate: @escaping () -> Void = {
            // Default empty delegate
        },
        title: String = "Ups!") {
        let locMessage = getLocalizedErrorMessage(message)
        if message.lowercased() == "unknown server error" {
            let alert = UIAlertController(title: title, message: locMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel) { (_) in
                delegate()
            })
            alert.addAction(UIAlertAction(title: "+ Información", style: .default) { (_) in
                if let url = URL(string: "https://status.pinely.app") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            })
            present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: title, message: locMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel) { (_) in
                delegate()
            })
            present(alert, animated: true, completion: nil)
        }
    }
}
