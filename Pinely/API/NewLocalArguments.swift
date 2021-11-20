//
//  NewLocalArguments.swift
//  Pinely
//

import Foundation

struct NewLocalArguments {
    var type: String
    var nameLocal: String
    var subTitle: String
    var description: String
    var ubication: String
    var idCountrie: Int
    var idCitie: Int
    var idTown: Int?

    var argumentsDictionary: [String: Any] {
        var typeProcessed = type
        if typeProcessed.lowercased() == "bar o pub" {
            typeProcessed = "bar"
        } else if typeProcessed.lowercased() == "discoteca" {
            typeProcessed = "discoteca"
        }

        var args: [String: Any] = [
            "type": typeProcessed,
            "name_local": nameLocal,
            "sub_title": subTitle,
            "description": description,
            "ubication": ubication,
            "id_countrie": idCountrie,
            "id_citie": idCitie
        ]

        if let idTown = idTown {
            args["id_town"] = idTown
        }

        return args
    }
}
