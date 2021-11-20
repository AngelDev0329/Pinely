//
//  Card.swift
//  Pinely
//

import Foundation

struct Card {
    var id: Int?
    var type: CardType?
    var number: String?
    var expirationMonth: Int?
    var expirationYear: Int?
    var security: Int?
    var nameOnCard: String?
    var last4: String?
    var paymentMethod: String?
    var fingerprint: String?

    init(type: CardType? = nil) {
        self.type = type
    }

    init(dict: [String: Any]) {
        self.id = dict.getInt("id")
        self.paymentMethod = dict.getString("payment_method")
        if let brand = dict.getString("brand")?.lowercased() {
            switch brand {
            case "visa": self.type = CardType.visa
            case "mastercard": self.type = CardType.masterCard
            default: self.type = nil
            }
        } else {
            self.type = nil
        }
        self.last4 = dict.getString("last4") ?? dict.getInt("last4")?.toString()
        self.fingerprint = dict.getString("fingerprint")
    }

    static let apple = Card(type: CardType.apple)
    static let bitcoin = Card(type: CardType.bitcoin)
    static let paypal = Card(type: CardType.paypal)
}
