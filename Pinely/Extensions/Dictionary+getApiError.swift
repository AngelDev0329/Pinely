//
//  Dictionary+getApiError.swift
//  Pinely
//

import Foundation

extension Dictionary where Key: ExpressibleByStringLiteral {
    func getApiError() -> NetworkError {
        var errorMsg = getString("error") ?? getString("msg") ?? "error.unknownServerError".localized
        if errorMsg == "incorrect_user_token" {
            errorMsg = "error.incorrectUserToken".localized
        } else if errorMsg == "email_not_verified_yet" {
            return NetworkError.emailNotVerified
        } else if errorMsg == "mobile_not_verified_yet" {
            return NetworkError.phoneNotVerified
        }
        return NetworkError.apiError(error: errorMsg)
    }
}
