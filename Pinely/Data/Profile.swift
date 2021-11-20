//
//  Profile.swift
//  Pinely
//

import Foundation

struct Profile {
    var name: String?
    var lastName: String?
    var mobilePhone: String?
    var dateOfBirth: String?
    var dniNumber: String?
    var cusIdStripe: String?
    var pushNotifications: String?
    var emailsNotifications: String?
    var pushPromoNotifications: String?
    var salesNotifications: String?
    var dailyResumNotifications: String?
    var paymentsNotifications: String?
    var emailVerification: String?
    var smsVerification: String?
    var dniVerification: String?
    var profilePurchases: String?
    var lastLogin: String?
    var accountCreation: String?
    var timeZone: String?
    var range: String?
    var username: String?

    init() {
        self.name = nil
        self.lastName = nil
        self.mobilePhone = nil
        self.dateOfBirth = nil
        self.dniNumber = nil
        self.cusIdStripe = nil
        self.pushNotifications = nil
        self.emailsNotifications = nil
        self.pushPromoNotifications = nil
        self.salesNotifications = nil
        self.dailyResumNotifications = nil
        self.paymentsNotifications = nil
        self.emailVerification = nil
        self.smsVerification = nil
        self.dniVerification = nil
        self.profilePurchases = nil
        self.lastLogin = nil
        self.accountCreation = nil
        self.timeZone = nil
        self.range = nil
        self.username = nil
    }

    init(dict: [String: Any]) {
        self.name = dict.getString("name")
        self.lastName = dict.getString("lastname")
        self.mobilePhone = dict.getString("mobile_phone")
        self.dateOfBirth = dict.getString("date_of_birth")
        self.dniNumber = dict.getString("DNI_number")
        self.cusIdStripe = dict.getString("cus_id_stripe")
        self.pushNotifications = dict.getString("push_notifications")
        self.emailsNotifications = dict.getString("emails_notifications")
        self.pushPromoNotifications = dict.getString("push_promo_notifications")
        self.salesNotifications = dict.getString("sales_notifications")
        self.dailyResumNotifications = dict.getString("daily_resum_notifications")
        self.paymentsNotifications = dict.getString("payments_notifications")
        self.emailVerification = dict.getString("email_verification")
        self.smsVerification = dict.getString("sms_verification")
        self.dniVerification = dict.getString("DNI_verification")
        self.profilePurchases = dict.getString("purchases")
        self.lastLogin = dict.getString("last_login")
        self.accountCreation = dict.getString("date_creation")
        self.timeZone = dict.getString("time_zone_value")
        self.range = dict.getString("range")
        self.username = dict.getString("user")
    }

    func getLastLoginDate() -> String {
        if let lastLogin = self.lastLogin,
           let date = DateFormatter.iso8601.date(from: lastLogin) {
            let dfOut = DateFormatter()
            dfOut.dateFormat = "dd/MM/yyyy HH:mm:ss"
            let dateString = dfOut.string(from: date)
            return "\(dateString)(UTC)"
        }
        return ""
    }

    func getDateByTimeZone() -> String {
        if let accountCreation = self.accountCreation,
           let date = DateFormatter.iso8601GMT.date(from: accountCreation) {
            let dfOut = DateFormatter()
            dfOut.timeZone = TimeZone(abbreviation: "GMT" + self.timeZone!)
            dfOut.dateFormat = "dd/MM/yyyy HH:mm:ss"
            return dfOut.string(from: date)
        }
        return ""
    }

    func toDict() -> [String: Any] {
        var result: [String: Any] = [:]
        if let name = self.name {
            result["name"] = name
        }
        if let lastname = self.lastName {
            result["lastname"] = lastname
        }
        if let mobilePhone = self.mobilePhone {
            result["mobile_phone"] = mobilePhone
        }
        if let dateOfBirth = self.dateOfBirth,
           let date = DateFormatter.iso8601.date(from: dateOfBirth) {
            let dfOut = DateFormatter()
            dfOut.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateString = dfOut.string(from: date)
            result["date_of_birth"] = dateString
        }
        if let dniNumber = self.dniNumber {
            result["DNI_number"] = dniNumber
        }
        if let cusIdStripe = self.cusIdStripe {
            result["cus_id_stripe"] = cusIdStripe
        }
        if let pushNotifications = self.pushNotifications {
            result["push_notifications"] = pushNotifications
        }
        if let emailsNotifications = self.emailsNotifications {
            result["emails_notifications"] = emailsNotifications
        }
        if let pushPromoNotifications = self.pushPromoNotifications {
            result["push_promo_notifications"] = pushPromoNotifications
        }
        if let salesNotifications = self.salesNotifications {
            result["sales_notifications"] = salesNotifications
        }
        if let dailyResumNotifications = self.dailyResumNotifications {
            result["daily_resum_notifications"] = dailyResumNotifications
        }
        if let paymentsNotifications = self.paymentsNotifications {
            result["payments_notifications"] = paymentsNotifications
        }
        if let emailVerification = self.emailVerification {
            result["email_verification"] = emailVerification
        }
        if let smsVerification = self.smsVerification {
            result["sms_verification"] = smsVerification
        }
        if let dniVerification = self.dniVerification {
            result["DNI_verification"] = dniVerification
        }
        return result
    }

    func getDOB() -> Date? {
        guard let dateOfBirth = self.dateOfBirth else {
            return nil
        }
        return DateFormatter.iso8601.date(from: dateOfBirth)
    }

    mutating func setDOB(date: Date) {
        self.dateOfBirth = DateFormatter.iso8601.string(from: date)
    }

    static var current: Profile?
    static var userToken: String?
}
