//
//  ShareLink.swift
//  Pinely
//

import Foundation

enum ShareLink {
    case dynamicLinksDomain
    case fallbackUrl

    case room(roomId: Int)
    case event(eventId: Int)

    var urlString: String {
        switch self {
        case .dynamicLinksDomain:
            return "https://pinely.page.link"

        case .fallbackUrl:
            return "https://pinely.app/error-link/"

        case .room(let roomId):
            return "https://pinely.net/room=\(roomId)"

        case .event(let eventId):
            return "https://pinely.net/event=\(eventId)"
        }
    }

    var url: URL? {
        URL(string: urlString)
    }
}
