//
//  Promocode.swift
//  Pinely
//

import Foundation

struct Promocode {
    var type: String?
    var code: String?
    var status: String?
    var quantity: Int = 0
    var onlyFirstPurchase: Bool = false
    var assumesDiscount: String?
    var validForAllLocals: Bool = false
    var validForAllEvents: Bool = false
    var validForAllTickets: Bool = false
    var idLocal: Int?
    var idEvent: Int?
    var idTicket: Int?
    var useTimes: Int = 0

    init(dict: [String: Any]) {
        type = dict.getString("type")
        code = dict.getString("code")
        status = dict.getString("status")
        quantity = dict.getInt("quantity") ?? 0
        onlyFirstPurchase = dict.getBoolean("only_first_purchase") ?? false
        assumesDiscount = dict.getString("assumes_discount")
        validForAllLocals = dict.getBoolean("valid_for_all_locals") ?? false
        validForAllEvents = dict.getBoolean("valid_for_all_events") ?? false
        validForAllTickets = dict.getBoolean("valid_for_all_tickets") ?? false
        idLocal = dict.getInt("id_local")
        idEvent = dict.getInt("id_event")
        idTicket = dict.getInt("id_ticket")
    }
}
