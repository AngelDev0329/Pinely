//
//  TicketStatus.swift
//  Pinely
//

import Foundation

enum TicketStatus {
    case notValidated
    case validated
    case rejected
    case mixed

    func getColor() -> UIColor {
        TicketStatus.statusColors[self]!
    }

    static let statusColors: [TicketStatus: UIColor] = [
        .notValidated: UIColor(named: "MainForegroundColor")!,
        .validated: UIColor(hex: 0x03E218)!,
        .rejected: UIColor(hex: 0xFF0000)!,
        .mixed: UIColor(hex: 0xFFA200)!
    ]
}
