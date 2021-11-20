//
//  Ticket.swift
//  Pinely
//

import Foundation

struct Ticket {
    var id: Int?
    var idEvent: Int?
    var position: Int?
    var name: String?
    var startValidation: Date?
    var finishValidation: Date?
    var currency: String?
    var priceTicket: Int?
    var ticketsToSale: Int?
    var remaining: Int?
    var gestionFee: Int?
    var insuranceFee: Int?
    var dateCreation: Date?
    var urlThumb: String?
    var ratio: Double?

    var amount: Int = 0

    init(dict: [String: Any]) {
        self.id = dict.getInt("id")
        self.idEvent = dict.getInt("id_event")
        self.position = dict.getInt("position")
        self.name = dict.getString("name")

        if let strStartValidation = dict.getString("start_validation") {
            startValidation = DateFormatter.iso8601.date(from: strStartValidation)
        }
        if let strFinishValidation = dict.getString("finish_validation") {
            finishValidation = DateFormatter.iso8601.date(from: strFinishValidation)
        }
        currency = dict.getString("currency")
        priceTicket = dict.getInt("price_ticket")
        ticketsToSale = dict.getInt("tickets_to_sale")
        remaining = dict.getInt("remaining")
        gestionFee = dict.getInt("gestion_fee")
        insuranceFee = dict.getInt("insurance_fee")
        if let strDateCreation = dict.getString("date_creation") {
            dateCreation = DateFormatter.iso8601.date(from: strDateCreation)
        }
        urlThumb = dict.getString("url_thumb")
        if let strRatio = dict.getString("ratio")?.filter("0123456789.,".contains)
            .replacingOccurrences(of: ",", with: "."),
           let dRatio = Double(strRatio) {
            ratio = dRatio / 100.0
        }
    }

    func getHourLimitString() -> String {
        guard let finishValidation = self.finishValidation else {
            return ""
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "H:mm"
        return dateFormatter.string(from: finishValidation)
    }
}
