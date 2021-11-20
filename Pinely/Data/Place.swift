//
//  Place.swift
//  Pinely
//

import Foundation

struct Place {
    var id: Int?
    var type: String
    var name: String
    var subTitle: String
    var thumbUrl: String?
    var avatarUrl: String?
    var featured: Bool
    var position: Int
    var dateCreation: Date?
    var latitude: Double?
    var longitude: Double?
    var status: Int?
    var areSelling: Bool?
    var tags: [String] = []

    static var dateFormat: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter
    }()

    init(dict: [String: Any]) {
        id = dict.getInt("id")
        type = dict.getString("type") ?? ""
        name = dict.getString("name") ?? ""
        position = dict.getInt("position") ?? 0
        subTitle = dict.getString("sub_title") ?? ""
        thumbUrl = dict.getString("thumb_url")
        avatarUrl = dict.getString("avatar_url")
        featured = dict.getString("featured") == "yes"
        status = dict.getInt("status")
        if let strDateCreation = dict.getString("date_creation") {
            dateCreation = Place.dateFormat.date(from: strDateCreation)
        } else {
            dateCreation = nil
        }
        if let location = dict.getString("ubication") {
            let latLng = location.components(separatedBy: ",")
            if latLng.count == 2 {
                latitude = Double(latLng[0].trimmingCharacters(in: .whitespacesAndNewlines))
                longitude = Double(latLng[1].trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
        if dict.getString("are_selling") == "yes" {
            areSelling = true
        } else if dict.getString("are_selling") == "no" {
            areSelling = false
        }
    }
}
