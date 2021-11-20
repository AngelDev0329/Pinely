//
//  Wallet.swift
//  Pinely
//

import UIKit

struct Wallet {
    var amount: Int
    var currencyWallet: String
    var symbolCurrency: String
    var decimalMark: String
    var thousandsSeparator: String
    var symbolFirst: Bool

    init() {
        amount = 0
        currencyWallet = "EUR"
        symbolCurrency = "€"
        decimalMark = ","
        thousandsSeparator = "."
        symbolFirst = false
    }

    init(dict: [String: Any]) {
        amount = dict.getInt("amount") ?? 0
        currencyWallet = dict.getString("currency_wallet") ?? "EUR"
        symbolCurrency = dict.getString("symbol_currency") ?? "€"
        decimalMark = dict.getString("decimal_mark") ?? ","
        thousandsSeparator = dict.getString("thousands_separator") ?? "."
        symbolFirst = (dict.getInt("symbol_first") ?? 0) > 0
    }

    func toString() -> String {
        let full = amount / 100
        let fractional = amount % 100

        let numberFormatter = NumberFormatter()
        numberFormatter.allowsFloats = false
        numberFormatter.groupingSize = 3
        numberFormatter.groupingSeparator = thousandsSeparator
        numberFormatter.usesGroupingSeparator = true
        // swiftlint:disable compiler_protocol_init
        let fullString = numberFormatter.string(from: NSNumber(integerLiteral: full))!
        let fractionalString = String(format: "%02d", fractional)

        var priceString = "\(fullString)\(decimalMark)\(fractionalString)"
        if symbolFirst {
            priceString = symbolCurrency + priceString
        } else {
            priceString += symbolCurrency
        }
        return priceString
    }
}
