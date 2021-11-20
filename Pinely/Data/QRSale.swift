//
//  QRSale.swift
//  Pinely
//

import Foundation

struct QRSale {
    var id: Int?
    var nameClient: String?
    var avatarClient: String?
    var QRCode: String?
    var number: Int = 0
    var validatedTickets: Int = 0
    var rejectTickets: Int = 0

    var status: TicketStatus

    init(dict: [String: Any]) {
        self.id = dict.getInt("id")
        self.nameClient = dict.getString("name_client")
        self.avatarClient = dict.getString("avatar_client")
        self.QRCode = dict.getString("QR_code")
        self.number = dict.getInt("number") ?? 0
        self.validatedTickets = dict.getInt("validated_tickets") ?? 0
        self.rejectTickets = dict.getInt("reject_tickets") ?? 0

        status = .notValidated
        calculateStatus()
    }

    mutating func calculateStatus() {
        if validatedTickets == number {
            status = .validated
        } else if rejectTickets == number {
            status = .rejected
        } else if validatedTickets > 0 {
            status = .mixed
        } else {
            status = .notValidated
        }
    }
}
