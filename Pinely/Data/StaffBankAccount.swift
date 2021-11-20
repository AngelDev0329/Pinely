//
//  StaffBankAccount.swift
//  Pinely
//

import Foundation

struct StaffBankAccount {
    var id: Int?
    var UID: String?
    var titular: String?
    var IBAN: String?
    var URLDocument: String?
    var status: String?
    var reason: String?
    var principalOrSecondaryBank: String?
    var country: String?
    var currency: String?
    var typeBank: String?

    init(dict: [String: Any]) {
        self.id = dict.getInt("id")
        self.UID = dict.getString("UID")
        self.titular = dict.getString("titular")
        self.IBAN = dict.getString("IBAN")
        self.URLDocument = dict.getString("URL_document")
        self.status = dict.getString("status")
        self.reason = dict.getString("reason")
        self.principalOrSecondaryBank = dict.getString("principal_or_secundary_bank")
        self.country = dict.getString("country")
        self.currency = dict.getString("currency")
        self.typeBank = dict.getString("type_bank")
    }
}
