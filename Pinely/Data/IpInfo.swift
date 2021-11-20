//
//  IpInfo.swift
//  Pinely
//

import Foundation

struct LocationInfo {
    var geonameId: String?
    var capital: String?
    var countryFlag: String?
    var countryFlagEmoji: String?
    var countryFlagEmojiUnicode: String?
    var callingCode: String?
    var isEU: Bool?

    init(dict: [String: Any]) {
        geonameId = dict.getString("geoname_id")
        capital = dict.getString("capital")
        countryFlag = dict.getString("country_flag")
        countryFlagEmoji = dict.getString("country_flag_emoji")
        countryFlagEmojiUnicode = dict.getString("country_flag_emoji_unicode")
        callingCode = dict.getString("calling_code")
        isEU = dict.getBoolean("is_eu")
    }
}

struct IpInfo {
    var ip: String
    var type: String?
    var continentCode: String?
    var continentName: String?
    var countryCode: String?
    var countryName: String?
    var regionCode: String?
    var regionName: String?
    var city: String?
    var zipCode: String?
    var latitude: Double?
    var longitude: Double?
    var location: LocationInfo?

    init?(dict: [String: Any]) {
        guard let ipAddress = dict.getString("ip") else {
            return nil
        }

        ip = ipAddress
        type = dict.getString("type")
        continentCode = dict.getString("continent_code")
        continentName = dict.getString("continent_name")
        countryCode = dict.getString("country_code")
        countryName = dict.getString("country_name")
        regionCode = dict.getString("region_code")
        regionName = dict.getString("region_name")
        city = dict.getString("city")
        zipCode = dict.getString("zip")
        latitude = dict.getDouble("latitude")
        longitude = dict.getDouble("longitude")
        if let locationDict = dict["location"] as? [String: Any] {
            location = LocationInfo(dict: locationDict)
        }
    }
}
