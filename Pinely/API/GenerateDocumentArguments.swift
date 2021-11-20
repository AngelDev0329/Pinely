//
//  GenerateDocumentArguments.swift
//  Pinely
//

import Foundation

struct GenerateDocumentsArguments {
    var documentId: Int
    var type: String
    var nameAgent: String
    var addressAgent: String
    var dniAgent: String
    var businessName: String
    var addressBusiness: String
    var cif: String
    var brand: String

    var argumentsDictionary: [String: Any] {
        [
            "document_id": documentId,
            "type": type,
            "name_agent": nameAgent,
            "address_agent": addressAgent,
            "dni_agent": dniAgent,
            "business_name": businessName,
            "address_business": addressBusiness,
            "cif": cif,
            "brand": brand
        ]
    }
}
