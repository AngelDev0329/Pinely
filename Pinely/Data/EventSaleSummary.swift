//
//  EventSaleSummary.swift
//  Pinely
//

import Foundation

struct EventSaleSummary {
    var ticketId: Int?
    var name: String?
    var totalSales: Int?
    var totalValidated: Int?
    var totalRejected: Int?

    init(dict: [String: Any]) {
        ticketId = dict.getInt("ticket_id")
        name = dict.getString("name")
        totalSales = dict.getInt("total_sales")
        totalValidated = dict.getInt("total_validated")
        totalRejected = dict.getInt("total_rejected")
    }
}
