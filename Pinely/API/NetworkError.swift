//
//  NetworkError.swift
//  Pinely
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case unauthenticated
    case serverError
    case apiError(error: String)
    case cardError
    case noToken
    case paymentError(dict: [String: Any])
    case declineIntent(paymentIntent: PaymentIntent)
    case emailNotVerified
    case phoneNotVerified

    var localizedDescription: String {
        switch self {
        case .unauthenticated: return "Unauthenticated"
        case .serverError: return "connection_failed".localized
        case .apiError(let error):
            switch error {
            case "date_out_range":
                return "event_finished_error".localized

            case "date_before_range":
                return "event_not_started_error".localized

            case "entry_not_found":
                return "ticket_not_found_error".localized

            default:
                return error
            }
        case .cardError: return "credit_card_not_valid_stripe".localized
        case .noToken: return "token_not_available".localized
        case .declineIntent(let paymentIntent):
            if let reason = paymentIntent.reason,
               let message = getErrorByDeclineCode(declineCode: reason) {
                return message
            }

            return NetworkError.defaultPaymentError

        case .paymentError(let dict):
            if let declineCode = dict.getString("decline_code"),
               let message = getErrorByDeclineCode(declineCode: declineCode) {
                return message
            }

            return NetworkError.defaultPaymentError

        case .emailNotVerified:
            return "You need to verify email before buying a ticket"

        case .phoneNotVerified:
            return "You need to verify phone number before buying a ticket"
        }
    }

    var errorDescription: String? {
        localizedDescription
    }

    static let defaultPaymentError = "Payment error"

    private func getErrorByDeclineCode(declineCode: String) -> String? {
        switch declineCode {
        case "insufficient_funds", "card_velocity_exceeded":
            return "insufficient_funds".localized

        case "do_not_honor", "transaction_not_allowed", "call_issuer",
            "do_not_try_again", "generic_decline", "incorrect_zip",
            "invalid_account", "invalid_amount", "issuer_not_available",
            "new_account_information_available", "no_action_taken",
            "not_permitted", "processing_error", "reenter_transaction",
            "security_violation", "try_again_later":
            return "payment_reject_stripe".localized

        case "duplicate_transaction":
            return "duplicate_transaction_error".localized

        case "fraudulent", "merchant_blacklist":
            return "fraudulent_payment_error".localized

        case "lost_card", "pickup_card", "restricted_card":
            return "lost_card_error".localized

        case "stolen_card":
            return "stolen_card_error".localized

        case "authentication_required", "incorrect_pin", "invalid_pin":
            return "auth_error_stripe".localized

        case "approve_with_id":
            return "error_verification_stripe".localized

        case "expired_card":
            return "expired_card_error".localized

        case "incorrect_number", "invalid_number":
            return "incorrect_number_stripe_error".localized

        case "incorrect_cvc", "invalid_cvc":
            return "incorrect_cvv_stripe_error".localized

        case "invalid_expiry_year":
            return "incorrect_expiration_stripe_error".localized

        default:
            return nil
        }
    }

    static let declineCodes = [
        "insufficient_funds", "card_velocity_exceeded",
        "do_not_honor", "transaction_not_allowed", "call_issuer",
        "do_not_try_again", "generic_decline", "incorrect_zip",
        "invalid_account", "invalid_amount", "issuer_not_available",
        "new_account_information_available", "no_action_taken",
        "not_permitted", "processing_error", "reenter_transaction",
        "security_violation", "try_again_later",
        "duplicate_transaction",
        "fraudulent", "merchant_blacklist",
        "lost_card", "pickup_card", "restricted_card",
        "stolen_card",
        "authentication_required", "incorrect_pin", "invalid_pin",
        "approve_with_id",
        "expired_card",
        "incorrect_number", "invalid_number",
        "incorrect_cvc", "invalid_cvc",
        "invalid_expiry_year"
    ]
    }
