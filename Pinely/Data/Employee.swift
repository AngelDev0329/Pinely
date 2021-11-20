//
//  Employee.swift
//  Pinely
//

import Foundation

struct Employee {
    var UID: String?
    var name: String?
    var lastname: String?
    var email: String?
    var range: String?
    var avatar: String?
    var idLocal: Int?

    init(dict: [String: Any]) {
        UID = dict.getString("UID")
        name = dict.getString("name")
        lastname = dict.getString("lastname")
        email = dict.getString("email")
        range = dict.getString("range")
        avatar = dict.getString("avatar")
        idLocal = dict.getInt("id_local")
    }
}
