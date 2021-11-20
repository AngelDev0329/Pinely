//
//  AppStoreReviewManager.swift
//  Pinely
//
//  Created by Alexander Nekrasov on 28.09.21.
//  Copyright © 2021 Francisco de Asis Jimenez Tirado. All rights reserved.
//

import StoreKit

enum AppStoreReviewManager {
    static func requestReviewIfAppropriate() {
        SKStoreReviewController.requestReview()
    }
}
