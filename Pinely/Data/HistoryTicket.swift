//
//  HistoryTicket.swift
//  Pinely
//

import Foundation

struct HistoryTicket {
    var id: Int
    var name: String?
    var number: Int = 0
    var urlThumb: String?
    var piReference: String?
    var status: String?
    var nameLocal: String?
    var finishEvent: Date?

    init(dict: [String: Any]) {
        id = dict.getInt("id") ?? 0
        name = dict.getString("name")
        number = dict.getInt("number") ?? 0
        urlThumb = dict.getString("url_thumb")
        piReference = dict.getString("pi_reference")
        status = dict.getString("status")
        nameLocal = dict.getString("local_name")
        if let strFinishEvent = dict.getString("finish_event") {
            finishEvent = DateFormatter.iso8601.date(from: strFinishEvent)
        }
    }

    func isUsed() -> Bool {
        status == "used"
    }
}
