//
//  City.swift
//  Pinely
//

import UIKit
import CoreLocation
import SwiftEventBus

struct Country {
    var id: Int
    var name: String

    init(dict: [String: Any]) {
        self.id = dict.getInt("id") ?? -1
        self.name = dict.getString("name_countrie") ?? ""
    }

    static var shared: [Country] = []
}

class CityOrTown {
    var id: Int = -1
    var position: Int = 0
    var name: String = ""
    var latitude: Double?
    var longitude: Double?

    init(dict: [String: Any]) {
        self.id = dict.getInt("id") ?? -1
        self.position = dict.getInt("position") ?? 0
        if let location = dict.getString("ubication") {
            let latLng = location.components(separatedBy: ",")
            if latLng.count == 2 {
                latitude = Double(latLng[0].trimmingCharacters(in: .whitespacesAndNewlines))
                longitude = Double(latLng[1].trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
    }

    static func chooseNearestTo(latitude: Double, longitude: Double) {
        var minDistance: Double?
        let coordinate = CLLocation(latitude: latitude, longitude: longitude)
        var allCitiesAndTowns: [CityOrTown] = []
        allCitiesAndTowns.append(contentsOf: City.shared)
        allCitiesAndTowns.append(contentsOf: Town.shared)
        let oldCurrent = current
        for town in allCitiesAndTowns {
            guard let townLat = town.latitude,
                  let townLng = town.longitude
            else { continue }

            let townCoordinate = CLLocation(latitude: townLat, longitude: townLng)
            let distanceInMeters = coordinate.distance(from: townCoordinate)
            if minDistance == nil || distanceInMeters < minDistance! {
                minDistance = distanceInMeters
                current = town
            }
        }

        // swiftlint:disable identifier_name
        if let old = oldCurrent,
           let cur = current {
            if old is City && cur is City && old.id == cur.id {
                return
            }
            if old is Town && cur is Town && old.id == cur.id {
                return
            }
        }
        SwiftEventBus.post("townUpdated")
    }

    func getFullName() -> String {
        return ""
    }

    static var current: CityOrTown? = nil {
        didSet {
            let userDefaults = UserDefaults.standard
            if let currentCity = current as? City {
                userDefaults.setValue(currentCity.id, forKey: StorageKey.userCity.rawValue)
                userDefaults.removeObject(forKey: StorageKey.userTown.rawValue)
            } else if let currentTown = current as? Town {
                userDefaults.setValue(currentTown.id, forKey: StorageKey.userTown.rawValue)
                if let currentCity = currentTown.city {
                    userDefaults.setValue(currentCity.id, forKey: StorageKey.userCity.rawValue)
                } else {
                    userDefaults.removeObject(forKey: StorageKey.userCity.rawValue)
                }
            } else {
                userDefaults.removeObject(forKey: StorageKey.userCity.rawValue)
                userDefaults.removeObject(forKey: StorageKey.userTown.rawValue)
            }
        }
    }

    static func loadCurrent() {
        let userDefaults = UserDefaults.standard
        let userCityId = userDefaults.integer(forKey: StorageKey.userCity.rawValue)
        let userTownId = userDefaults.integer(forKey: StorageKey.userTown.rawValue)
        if userTownId > 0 {
            current = Town.shared.first(where: { $0.id == userTownId })
        } else if userCityId > 0 {
            current = City.shared.first(where: { $0.id == userCityId })
        } else {
            current = nil
        }
    }
}

class City: CityOrTown {
    var idCountry: Int?

    override init(dict: [String: Any]) {
        super.init(dict: dict)

        self.name = dict.getString("name_city") ?? ""
        self.idCountry = dict.getInt("id_countrie")
    }

    override func getFullName() -> String {
        var n = "\(self.name)"
        if let c = self.country {
            n += ", \(c.name)"
        }
        return n
    }

    var country: Country? {
        Country.shared.first(where: { $0.id == idCountry })
    }

    static var shared: [City] = []
}

class Town: CityOrTown {
    var idCity: Int?

    override init(dict: [String: Any]) {
        super.init(dict: dict)

        self.name = dict.getString("name_town") ?? ""
        self.idCity = dict.getInt("id_city")
    }

    override func getFullName() -> String {
        var n = "\(self.name)"
        if let c = self.city {
            n += ", \(c.name)"

            if let c2 = c.country {
                n += ", \(c2.name)"
            }
        }
        return n
    }

    var city: City? {
        City.shared.first(where: { $0.id == idCity })
    }

    var country: Country? {
        Country.shared.first(where: { $0.id == city?.idCountry })
    }

    static var shared: [Town] = []
}
