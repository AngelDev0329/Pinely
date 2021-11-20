//
//  TransactionInfo.swift
//  Pinely
//

import Foundation

struct TransactionInfo {
    struct Refund {
        var id: Int?
        var ticketsRefunds: Int?
        var quantityRefund: Int?
        var methodRefund: String?
        var dateRefund: Date?

        init(dict: [String: Any]) {
            self.id = dict.getInt("id")
            self.ticketsRefunds = dict.getInt("tickets_refunds")
            self.quantityRefund = dict.getInt("quantity_refund")
            self.methodRefund = dict.getString("method_refund")
            if let strDateRefund = dict.getString("date_refund") {
                self.dateRefund = DateFormatter.iso8601.date(from: strDateRefund)
            }
        }
    }

    var id: Int?
    var priceTicket: Int = 0
    var ticketsNumber: Int = 1
    var subTotal: Int = 0
    var gestionFee: Int = 0
    var amountPayment: Int = 0
    var amountPromoCodeUsed: Int = 0
    var amountWalledUsed: Int = 0
    var paymentMethod: String?
    var brand: String?
    var last4: String?
    var ubication: String?
    var invoiceUrl: String?
    var refunds: [Refund] = []

    init(dict: [String: Any]) {
        self.id = dict.getInt("id")
        self.priceTicket = dict.getInt("price_ticket") ?? 0
        self.ticketsNumber = dict.getInt("tickets_number") ?? 1
        self.subTotal = dict.getInt("subtotal") ?? 0
        self.gestionFee = dict.getInt("gestion_fee") ?? 0
        self.amountPayment = dict.getInt("amount_payment") ?? 0
        self.amountPromoCodeUsed = dict.getInt("amount_promocode_used") ?? 0
        self.amountWalledUsed = dict.getInt("amount_wallet_used") ?? 0
        self.paymentMethod = dict.getString("payment_method")
        self.brand = dict.getString("brand")
        self.last4 = dict.getString("last4")
        self.ubication = dict.getString("ubication")
        self.invoiceUrl = dict.getString("invoice_url")

        if let refundDict = dict["refunds"] as? [String: Any] {
            refunds = [
                Refund(dict: refundDict)
            ]
        } else if let refundsArr = dict["refunds"] as? [Any] {
            refunds = refundsArr
                .compactMap { $0 as? [String: Any] }
                .map { Refund(dict: $0) }
        }
    }
}
