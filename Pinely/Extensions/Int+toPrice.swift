//
//  Int+toPrice.swift
//  Pinely
//

import Foundation

extension Int {
    func toPrice() -> String {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = "."
        formatter.groupingSize = 3
        formatter.usesGroupingSeparator = true
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        let euros = formatter.string(from: NSNumber(value: self / 100)) ?? "?"
        return euros +
            String(format: ",%02d", self % 100) +
            "€"
    }
}
