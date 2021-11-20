//
//  QRInfo.swift
//  Pinely
//

import Foundation

struct QRInfo {
    var number: Int = 0
    var localId: Int = -1
    var eventId: Int = -1
    var ticketId: Int = -1
    var validatedTickets: Int = 0
    var rejectedTickets: Int = 0
    var clientName: String = ""
    var eventName: String = ""
    var nameTickets: String = ""
    var username: String = ""
    var birthDate: Date?
    var NIF: String = ""
    var commentTicket: String = ""
    var avatarClient: String?
    var dateValidation: Date?
    var dateRejection: Date?
    var rangeValue: String?
    var status: String?
    var verificationClient: String?
    var finishValidationTicket: Date?

    var ticketStatus: TicketStatus

    init(dict: [String: Any]) {
        self.number = dict.getInt("number") ?? 0
        self.localId = dict.getInt("local_id") ?? -1
        self.eventId = dict.getInt("event_id") ?? -1
        self.ticketId = dict.getInt("ticket_id") ?? -1
        self.validatedTickets = dict.getInt("validated_tickets") ?? 0
        self.rejectedTickets = dict.getInt("rejected_tickets") ?? 0
        self.clientName = dict.getString("client_name") ?? ""
        self.eventName = dict.getString("event_name") ?? ""
        self.nameTickets = dict.getString("name_tickets") ?? ""
        self.username = dict.getString("username") ?? ""
        if let strBirthDate = dict.getString("birth_date") {
            self.birthDate = DateFormatter.iso8601GMT.date(from: strBirthDate)
        }
        if let strDateValidation = dict.getString("date_validation") {
            self.dateValidation = DateFormatter.iso8601GMT.date(from: strDateValidation)
        }
        if let strDateRejection = dict.getString("date_rejection") {
            self.dateRejection = DateFormatter.iso8601GMT.date(from: strDateRejection)
        }
        self.NIF = dict.getString("NIF") ?? ""
        self.commentTicket = dict.getString("comment_ticket") ?? ""
        self.avatarClient = dict.getString("avatar_client")
        self.rangeValue = dict.getString("range_value")
        self.status = dict.getString("status")
        self.verificationClient = dict.getString("verification_client")
        if let strFinishValidationTicket = dict.getString("finish_validation_ticket") {
            self.finishValidationTicket = DateFormatter.iso8601GMT.date(from: strFinishValidationTicket)
        }

        ticketStatus = .notValidated
        calculateStatus()
    }

    mutating func calculateStatus() {
        if validatedTickets == number {
            ticketStatus = .validated
        } else if rejectedTickets == number {
            ticketStatus = .rejected
        } else if validatedTickets > 0 {
            ticketStatus = .mixed
        } else {
            ticketStatus = .notValidated
        }
    }

    func getStatusText() -> String {
        switch ticketStatus {
        case .notValidated: return "Sin validar"
        case .validated:
            if number == 1 {
                return "Validada"
            } else {
                return "Validadas"
            }

        case .rejected:
            if number == 1 {
                return "Rechazada"
            } else {
                return "Rechazadas"
            }

        case .mixed:
            if number == 1 {
                return "Mixto"
            } else {
                return "Mixtos"
            }
        }
    }

    func isUserVerified() -> Bool {
        self.verificationClient == "user_verified"
    }
}
