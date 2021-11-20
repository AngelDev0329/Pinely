//
//  Photo.swift
//  Pinely
//

import Foundation
import FirebaseAuth

protocol PhotoFakeOrReal {
    var URLThumb: String? { get }
    var URLFull: String? { get }
    var status: String? { get }
    var UID: String? { get }
}

struct Photo: PhotoFakeOrReal {
    var URLThumb: String?
    var URLFull: String?
    var status: String?
    var UID: String?

    init(dict: [String: Any]) {
        self.URLThumb = dict.getString("URL_thumb")
        self.URLFull = dict.getString("URL_full")
        self.status = dict.getString("status")
        self.UID = dict.getString("UID")
    }

    init(urlLocal: String) {
        self.URLThumb = urlLocal
        self.URLFull = urlLocal
        self.status = "pending"
        self.UID = Auth.auth().currentUser?.uid
    }
}

extension Array where Element == PhotoFakeOrReal {
    func filterForUser() -> [Element] {
        if let uid = Auth.auth().currentUser?.uid {
            return filter { $0.status == "ready" || ($0.status == "pending" && $0.UID == uid) }
        } else {
            return filter { $0.status == "ready" }
        }
    }
}

extension PhotoFakeOrReal {
    var hasOrangeFrame: Bool {
        status == "pending"
    }
}
