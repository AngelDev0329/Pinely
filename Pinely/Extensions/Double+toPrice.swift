//
//  Double+toPrice.swift
//  Pinely
//

import Foundation

extension Double {
    func toPrice() -> String {
        let formatter = NumberFormatter()
        formatter.decimalSeparator = ","
        formatter.groupingSeparator = "."
        formatter.groupingSize = 3
        formatter.usesGroupingSeparator = true
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return (formatter.string(from: NSNumber(value: self)) ?? "?") + "€"
    }
}
