//
//  RouteJS.swift
//  Pinely
//

import Foundation

enum RouteJS: String, CaseIterable {
    case finishRegistration = "finishRegistration"
    case checkClient = "checkClient"
    case location = "location"
    case updateUser = "updateUser"
    case updateNotifications = "updateNotifications"
    case informationLocal = "information_local"
    case eventInformation = "eventInformation"
    case userStatus = "userStatus"
    case eventStatus = "eventStatus"
    case userCanUploadPhotos = "userCanUploadPhotos"
    case checkIfPromocodeUsed = "checkIfPromocodeUsed"
    case room = "room"
    case uploadLocalImage = "/upload/local/$idLocal/$type"

    var url: String {
        "\(RouteJS.baseUrl)/\(rawValue)"
    }

    static let baseUrl = "https://cloud.pinely.net"
}
