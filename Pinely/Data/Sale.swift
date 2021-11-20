//
//  Sale.swift
//  Pinely
//

import Foundation

struct Sale {
    var id: Int?
    var number: Int?
    var localId: Int?
    var eventId: Int?
    var ticketId: Int?
    var validatedTickets: Int?
    var rejectTickets: Int?
    var UID: String?
    var ipAddress: String?
    var promoUsed: String?
    var insurance: Bool = false
    var paymentMethod: String?
    var brand: String?
    var last4: String?
    var platform: String?
    var versionApp: String?
    var QRCode: String?
    var currency: String?
    var amountPayment: Int?
    var piReference: String?
    var datePurchase: Date?
    var invoiceUrl: String?

    init(dict: [String: Any]) {
        id = dict.getInt("id")
        number = dict.getInt("number")
        localId = dict.getInt("local_id")
        eventId = dict.getInt("event_id")
        ticketId = dict.getInt("ticket_id")
        validatedTickets = dict.getInt("validated_tickets")
        rejectTickets = dict.getInt("reject_tickets")
        UID = dict.getString("UID")
        ipAddress = dict.getString("ip_address")
        promoUsed = dict.getString("promo_used")
        insurance = dict.getBoolean("insurance") ?? false
        paymentMethod = dict.getString("payment_method")
        brand = dict.getString("brand")
        last4 = dict.getString("last4")
        platform = dict.getString("platform")
        versionApp = dict.getString("version_app")
        QRCode = dict.getString("QR_code")
        currency = dict.getString("currency")
        amountPayment = dict.getInt("amount_payment")
        piReference = dict.getString("pi_reference")
        invoiceUrl = dict.getString("invoice_url")

        if let strDate = dict.getString("date_purchase") {
            datePurchase = DateFormatter.iso8601.date(from: strDate)
        }
    }
}
