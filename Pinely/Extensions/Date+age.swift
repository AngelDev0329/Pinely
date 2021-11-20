//
//  Date+age.swift
//  Pinely
//

import Foundation

extension Date {
    // swiftlint:disable identifier_name
    var age: Int {
        let calendar = Calendar.current
        let dateNow = Date()
        let ageComponents = calendar.dateComponents([.year], from: self, to: dateNow)
        return ageComponents.year!
    }
}
