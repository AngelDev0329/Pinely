//
//  EventInfo.swift
//  Pinely
//

import Foundation

struct EventInfo {
    var urlThumb: String?
    var urlPoster: String?
    var avatarLocal: String?
    var nameEvent: String?
    var startEvent: Date?
    var eventInformational: Bool = false
    var urlButtonExternal: String?

    init(dict: [String: Any]) {
        urlThumb = dict.getString("url_thumb")
        urlPoster = dict.getString("url_poster")
        avatarLocal = dict.getString("avatar_local")
        nameEvent = dict.getString("name_event")
        eventInformational = dict.getBoolean("event_informational") ?? false
        urlButtonExternal = dict.getString("url_button_external")

        if let strStartEvent = dict.getString("start_event") {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            startEvent = dateFormatter.date(from: strStartEvent)
        }
    }
}
