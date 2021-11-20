//
//  String+isValidIBAN.swift
//  Pinely
//

import Foundation

extension String {
    // swiftlint:disable identifier_name
    var isValidIBAN: Bool {
        var a = self.utf8.map { $0 }
        while a.count < 4 {
            a.append(0)
        }
        let b = a[4..<a.count] + a[0..<4]
        let c = b.reduce(0) { (r, u) -> Int in
            let i = Int(u)
            return i > 64 ? (100 * r + i - 55) % 97: (10 * r + i - 48) % 97
        }
        return c == 1
    }
}
