//
//  Purchase.swift
//  Pinely
//

import Foundation

struct Purchase {
    var id: Int?
    var name: String?
    var avatarUrl: String?
    var amount: Int?
    var payment: String?
    var date: Date?
    var timeZoneValue: String?

    init(dict: [String: Any]) {
        self.id = dict.getInt("id")
        self.name = dict.getString("name")
        self.amount = dict.getInt("amount")
        self.payment = dict.getString("payment")
        self.avatarUrl = dict.getString("avatar")
        self.timeZoneValue = dict.getString("time_zone_value")
        if let strDate = dict.getString("datepurchase") {
            self.date = DateFormatter.iso8601GMT.date(from: strDate)
        }
    }
}
