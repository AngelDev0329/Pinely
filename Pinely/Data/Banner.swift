//
//  Banner.swift
//  Pinely
//

import Foundation

struct Banner {
    var title: String
    var message: String
    var link: String

    init(dict: [String: Any]) {
        title = dict.getString("title") ?? ""
        message = dict.getString("message") ?? ""
        link = dict.getString("link") ?? ""
    }
}
