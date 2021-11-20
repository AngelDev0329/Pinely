//
//  PaymentProgress.swift
//  Pinely
//

import Foundation
import FirebaseAuth

struct PaymentProgress {
    var upid: String
    var roomId: Int
    var eventId: Int
    var ticketId: Int
    var isApplePay: Bool = false
    var paymentMethodId: String?
    var paymentStarted: Bool = false
    var verificationRequired: Bool = false
    var ticketCount: Int = 0
    var amountToPay: Int = 0
    var amountWallet: Int = 0
    var amountPromo: Int = 0
    var promoCode: String?

    init(upid: String, roomId: Int, eventId: Int, ticketId: Int) {
        self.upid = upid
        self.roomId = roomId
        self.eventId = eventId
        self.ticketId = ticketId
    }

    init?() {
        guard let ppKey = PaymentProgress.getKey(),
              let dict = UserDefaults.standard.value(forKey: ppKey) as? [String: Any]
        else {
            return nil
        }

        upid = dict.getString("upid") ?? ""
        roomId = dict.getInt("roomId") ?? 0
        eventId = dict.getInt("eventId") ?? 0
        ticketId = dict.getInt("ticketId") ?? 0
        isApplePay = dict.getBoolean("isApplePay") ?? false
        paymentMethodId = dict.getString("paymentMethodId")
        paymentStarted = dict.getBoolean("paymentStarted") ?? false
        verificationRequired = dict.getBoolean("verificationRequired") ?? false
        ticketCount = dict.getInt("ticketCount") ?? 0
        amountToPay = dict.getInt("amountToPay") ?? 0
        amountWallet = dict.getInt("amountWallet") ?? 0
        amountPromo = dict.getInt("amountPromo") ?? 0
        promoCode = dict.getString("promoCode")
    }

    func save() {
        guard let ppKey = PaymentProgress.getKey() else {
            return
        }

        var dict: [String: Any] = [
            "upid": upid,
            "roomId": roomId,
            "eventId": eventId,
            "ticketId": ticketId,
            "isApplePay": isApplePay,
            "paymentStarted": paymentStarted,
            "verificationRequired": verificationRequired,
            "ticketCount": ticketCount,
            "amountToPay": amountToPay,
            "amountWallet": amountWallet,
            "amountPromo": amountPromo
        ]
        if let paymentMethodId = paymentMethodId {
            dict["paymentMethodId"] = paymentMethodId
        }
        if let promoCode = promoCode {
            dict["promoCode"] = promoCode
        }

        UserDefaults.standard.set(dict, forKey: ppKey)
    }

    static func reset() {
        current = nil

        if let ppKey = PaymentProgress.getKey() {
            UserDefaults.standard.removeObject(forKey: ppKey)
        }
    }

    static func getKey() -> String? {
        if let uid = Auth.auth().currentUser?.uid {
            return "\(PaymentProgress.baseKey).\(uid)"
        } else {
            return nil
        }
    }

    private static let baseKey = "pinely.payment_progress"
    static var current: PaymentProgress?
}
