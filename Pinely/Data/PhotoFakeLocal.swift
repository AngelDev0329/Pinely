//
//  PhotoFakeLocal.swift
//  Pinely
//

import Foundation
import FirebaseAuth

struct PhotoFakeLocal: PhotoFakeOrReal {
    var URLThumb: String?
    var URLFull: String?
    var status: String?
    var UID: String?
    var after: String?

    init(url: String, after: String?) {
        self.URLThumb = url
        self.URLFull = url
        self.status = "pending"
        self.UID = Auth.auth().currentUser?.uid
        self.after = after
    }

    static func load() -> [PhotoFakeLocal] {
        guard let uid = Auth.auth().currentUser?.uid,
            let photosFakeArray = UserDefaults.standard.array(forKey: "photos.fake.\(uid)")
            else { return [] }

        let dictArr = photosFakeArray.compactMap { $0 as? [String: Any] }
        var result: [PhotoFakeLocal] = []
        dictArr.forEach {
            if let url = $0.getString("url") {
                let after = $0.getString("after")
                result.append(PhotoFakeLocal(url: url, after: after))
            }
        }
        return result
    }

    static func save(photos: [PhotoFakeLocal]) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        var result: [[String: Any]] = []
        photos.forEach {
            if let url = $0.URLFull {
                var item: [String: Any] = ["url": url]
                if let after = $0.after {
                    item["after"] = after
                }
                result.append(item)
            }
        }

        UserDefaults.standard.set(result, forKey: "photos.fake.\(uid)")
    }
}
