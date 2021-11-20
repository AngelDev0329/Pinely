//
//  Event.swift
//  Pinely
//

import Foundation

struct Event {
    var id: Int?
    var idLocal: Int?
    var position: Int
    var name: String
    var subTitle: String?
    var description: String?
    var urlThumb: String?
    var urlPoster: String?
    var ageMin: Int?
    var startEvent: Date?
    var finishEvent: Date?
    var eventInformational: Bool = false
    var urlButtonExternal: String?
    var clothesRule: Int?
    var startSell: Date?
    var closeSell: Date?
    var status: String?
    var dateCreation: Date?

    init(dict: [String: Any]) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        id = dict.getInt("id")
        idLocal = dict.getInt("id_local")
        position = dict.getInt("position") ?? 0
        name = dict.getString("name") ?? ""
        subTitle = dict.getString("sub_title")
        description = dict.getString("description")
        urlThumb = dict.getString("url_thumb")
        urlPoster = dict.getString("url_poster")
        ageMin = dict.getInt("age_min")
        if let strStartEvent = dict.getString("start_event") {
            startEvent = dateFormatter.date(from: strStartEvent) ?? DateFormatter.iso8601.date(from: strStartEvent)
        }
        if let strFinishEvent = dict.getString("finish_event") {
            finishEvent = dateFormatter.date(from: strFinishEvent) ?? DateFormatter.iso8601.date(from: strFinishEvent)
        }
        eventInformational = dict.getBoolean("event_informational") ?? false
        urlButtonExternal = dict.getString("url_button_external")
        clothesRule = dict.getInt("clothes_rule")
        if let strStartSell = dict.getString("start_sell") {
            startSell = dateFormatter.date(from: strStartSell) ?? DateFormatter.iso8601.date(from: strStartSell)
        }
        if let strCloseSell = dict.getString("close_sell") {
            closeSell = dateFormatter.date(from: strCloseSell) ?? DateFormatter.iso8601.date(from: strCloseSell)
        }
        status = dict.getString("status")
        if let strDateCreation = dict.getString("date_creation") {
            dateCreation = dateFormatter.date(from: strDateCreation) ?? DateFormatter.iso8601.date(from: strDateCreation)
        }
    }
}
