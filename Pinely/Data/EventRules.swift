//
//  EventRules.swift
//  Pinely
//

import Foundation

struct EventRules {
    var clothesRule: Int?
    var ageMin: Int?
    var priceMoreLow: Int?

    init(dict: [String: Any]) {
        clothesRule = dict.getInt("clothes_rule")
        ageMin = dict.getInt("age_min")
        priceMoreLow = dict.getInt("price_more_low")
    }

    var clothesRuleText: String? {
        guard let clothesRule = clothesRule else {
            return nil
        }
        switch clothesRule {
        case 1: return "Formal"
        case 2: return "Arreglada"
        case 3: return "Casual"
        case 4: return "Free Style"
        default: return nil
        }
    }
}
