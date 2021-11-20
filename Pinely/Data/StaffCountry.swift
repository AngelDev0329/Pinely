//
//  Country.swift
//  Pinely
//

import Foundation

struct StaffCountry {
    var code: String
    var flagUrl: String?
    var name: String?

    init(code: String, flagUrl: String?) {
        self.code = code
        self.flagUrl = flagUrl

        let codeLc = code.lowercased()
        self.name = StaffCountry.countryNames.first(where: { $0.getString("alpha2") == codeLc })?.getString("name")
    }

    init?(dict: [String: Any]) {
        guard let code = dict.getString("country") else { return nil }

        self.code = code
        self.flagUrl = dict.getString("URL_icon_flag")

        let codeLc = code.lowercased()
        self.name = StaffCountry.countryNames.first(where: { $0.getString("alpha2") == codeLc })?.getString("name")
    }

    func getName() -> String {
        name ?? code
    }

    static var countryNames: [[String: Any]] = []
    static func loadCountryNames(lang: String) {
        if let fileURL = Bundle.main.url(
            forResource: "Countries_\(lang.lowercased())",
            withExtension: "json"),
           let data = try? Data(contentsOf: fileURL),
           let jsonArray = try? JSONSerialization.jsonObject(
            with: data, options: .allowFragments),
           let arrOfObjects = jsonArray as? [[String: Any]] {
            countryNames = arrOfObjects
        }
    }
}
