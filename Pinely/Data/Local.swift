//
//  Local.swift
//  Pinely
//

import Foundation
import CoreLocation
import UIKit

struct Local {
    var place: Place?
    var localName: String?
    var subTitle: String?
    var localCityId: Int?
    var localTownId: Int?
    var localCountry: String?
    var localCity: String?
    var localTown: String?
    var avatar: String?
    var thumb: String?
    var interiorUrl: String?
    var areSelling: Bool = false
    var ubication: CLLocationCoordinate2D?
    var information: String?
    var instagram: String?
    var status: Int = 0
    var events: [Event] = []
    var photos: [PhotoFakeOrReal] = []

    init(place: Place?, dict: [String: Any]) {
        self.place = place
        self.localName = dict.getString("local_name") ?? dict.getString("name")
        self.subTitle = dict.getString("local_sub_title") ?? dict.getString("sub_title")
        self.localCityId = dict.getInt("local_city_id") ?? dict.getInt("id_citie")
        self.localTownId = dict.getInt("local_town_id") ?? dict.getInt("id_town")
        self.localCountry = dict.getString("local_countrie")
        self.localCity = dict.getString("local_city")
        self.localTown = dict.getString("local_town")
        self.avatar = dict.getString("avatar") ?? dict.getString("avatar_url")
        self.thumb = dict.getString("thumb") ?? dict.getString("thumb_url")
        self.interiorUrl = dict.getString("interior_url")
        self.areSelling = dict.getBoolean("are_selling") ?? false
        self.instagram = dict.getString("instagram")
        self.status = dict.getInt("status") ?? place?.status ?? 0
        if let strUbication = dict.getString("ubication") {
            let components = strUbication.components(separatedBy: ",")
            if components.count == 2,
               let latitude = Double(components[0].trimmingCharacters(in: .whitespacesAndNewlines)),
               let longitude = Double(components[1].trimmingCharacters(in: .whitespacesAndNewlines)) {
                self.ubication = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            }
        }
        self.information = dict.getString("information")
        if let arrEvents = dict["events"] as? [Any] {
            events = arrEvents
                .compactMap {
                    $0 as? [String: Any]
                }
                .map {
                    var event = Event(dict: $0)
                    if event.idLocal == nil {
                        event.idLocal = place?.id
                    }
                    return event
                }
        }
        if let arrPhotos = dict["photos"] as? [Any] {
            photos = arrPhotos
                .compactMap {
                    $0 as? [String: Any]
                }
                .map {
                    Photo(dict: $0)
                }
                .filterForUser()

            // Insert fake photos
            let fakePhotos = PhotoFakeLocal.load()
            if !fakePhotos.isEmpty {
                var newPhotos: [PhotoFakeOrReal] = []
                newPhotos.append(contentsOf: fakePhotos.filter { $0.after == nil })
                photos.forEach { (photo) in
                    newPhotos.append(photo)
                    let newFake = fakePhotos.filter { $0.after == photo.URLFull }
                    if !newFake.isEmpty {
                        newPhotos.append(contentsOf: newFake)
                    }
                }
                photos = newPhotos
            }

            photos = photos
                .reversed()
        }
    }

    var instagramURL: URL? {
        if let instagram = self.instagram {
            if let url = URL(string: "instagram://user?username=\(instagram)"),
               UIApplication.shared.canOpenURL(url) {
                return url
            } else {
                return URL(string: "https://instagram.com/\(instagram)")
            }
        } else {
            return nil
        }
    }

    func openInstagram() -> Bool {
        guard let url = instagramURL else { return false }

        if !UIApplication.shared.canOpenURL(url) {
            return false
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        return true
    }
}
