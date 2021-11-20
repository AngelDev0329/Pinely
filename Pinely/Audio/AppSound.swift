//
//  AppSount.swift
//  Pinely
//
//  Created by Alexander Nekrasov on 19.08.21.
//  Copyright © 2021 Francisco de Asis Jimenez Tirado. All rights reserved.
//

import Foundation

enum AppSound: String, CaseIterable {
    case logOut = "log_out"
    case uiRefreshFeed = "ui_refresh_feed"
    case toggleOn = "toggle_on"
    case toggleOff = "toggle_off"
    case purchasedSuccessfully = "purchased_successfully"
    case confirmation = "confirmation"

    func play() {
        rawValue.playSound()
    }
}
