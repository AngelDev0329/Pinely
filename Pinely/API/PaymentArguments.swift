//
//  PaymentArguments.swift
//  Pinely
//

import Foundation

struct PaymentArguments {
    var upid: String
    var idLocal: Int
    var idEvent: Int
    var idTicket: Int
    var ticketNumber: Int
    var amount: Int /* in cents */
    var paymentMethod: String
    var amountWallet: Int
    var amountPromo: Int
    var promoCode: String?

    var argumentsDictionary: [String: Any] {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

        var args: [String: Any] = [
            "platform": "iOS",
            "app_version": appVersion ?? "Unknown",
            "id_local": idLocal,
            "id_event": idEvent,
            "id_ticket": idTicket,
            "ticket_number": ticketNumber,
            "amount": amount,
            "payment_method": paymentMethod,
            "amount_wallet": amountWallet,
            "amount_promo": amountPromo,
            "force_3ds": 0,
            "upid": upid
        ]

        if let promoCode = promoCode {
            args["promo_code"] = promoCode
        }

        return args
    }
}
