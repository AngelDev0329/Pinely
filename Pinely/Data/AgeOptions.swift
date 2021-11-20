//
//  AgeOptions.swift
//  Pinely
//

import Foundation

class AgeOptions {
    static let options = [
        0,
        14,
        15,
        16,
        17,
        18,
        19,
        20,
        21,
        22,
        23,
        24,
        25,
        26,
        27,
        28,
        29,
        30
    ]

    static let textsEdit = [
        0: "Sin edad mínima",
        14: "14",
        15: "15",
        16: "16",
        17: "17",
        18: "18",
        19: "19",
        20: "20",
        21: "21",
        22: "22",
        23: "23",
        24: "24",
        25: "25",
        26: "26",
        27: "27",
        28: "28",
        29: "29",
        30: "30"
    ]

    static func getTextEditFor(_ ageMin: Int) -> String {
        textsEdit[ageMin] ?? "\(ageMin)"
    }

    static let textsView = [
        0: "Cualquiera",
        14: "14 años",
        15: "15 años",
        16: "16 años",
        17: "17 años",
        18: "18 años",
        19: "19 años",
        20: "20 años",
        21: "21 años",
        22: "22 años",
        23: "23 años",
        24: "24 años",
        25: "25 años",
        26: "26 años",
        27: "27 años",
        28: "28 años",
        29: "29 años",
        30: "30 años"
    ]

    static func getTextViewFor(_ ageMin: Int) -> String {
        textsView[ageMin] ?? "\(ageMin) años"
    }
}
