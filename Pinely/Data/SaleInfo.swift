//
//  SaleInfo.swift
//  Pinely
//

import Foundation
import CoreLocation

struct SaleInfo {
    var localName: String?
    var avatarUrl: String?
    var thumbUrl: String?
    var name: String?
    var QRCode: String?
    var number: Int = 1
    var startEvent: Date?
    var finishEvent: Date?
    var startValidation: Date?
    var finishValidation: Date?
    var clothesRule: Int = 0
    var ageMin: Int = 18
    var ubication: CLLocationCoordinate2D?

    init() {
        // Initializer creates an object with default values
    }

    init(dict: [String: Any]) {
        localName = dict.getString("local_name")
        avatarUrl = dict.getString("avatar_url")
        thumbUrl = dict.getString("thumb_url")
        name = dict.getString("name")
        QRCode = dict.getString("QR_code")
        number = dict.getInt("number") ?? 1

        if let strStartEvent = dict.getString("start_event") {
            startEvent = DateFormatter.iso8601.date(from: strStartEvent)
        }
        if let strFinishEvent = dict.getString("finish_event") {
            finishEvent = DateFormatter.iso8601.date(from: strFinishEvent)
        }
        if let strStartValidation = dict.getString("start_validation") {
            startValidation = DateFormatter.iso8601.date(from: strStartValidation)
        }
        if let strFinishValidation = dict.getString("finish_validation") {
            finishValidation = DateFormatter.iso8601.date(from: strFinishValidation)
        }

        clothesRule = dict.getInt("clothes_rule") ?? 0
        ageMin = dict.getInt("age_min") ?? 18
        if let strUbication = dict.getString("ubication") {
            let components = strUbication.components(separatedBy: ",")
            if components.count == 2,
               let latitude = Double(components[0].trimmingCharacters(in: .whitespacesAndNewlines)),
               let longitude = Double(components[1].trimmingCharacters(in: .whitespacesAndNewlines)) {
                self.ubication = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            }
        }
    }
}
