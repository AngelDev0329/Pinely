//
//  Int+centsToEuros.swift
//  Pinely
//

import Foundation

extension Int {
    func centsToEuros() -> Double? {
        Double(self) / 100.0 + 0.001
    }
}
