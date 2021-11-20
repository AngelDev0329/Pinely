//
//  StaffDocument.swift
//  Pinely
//

import Foundation

struct StaffDocument {
    var id: Int?
    var nameFile: String?
    var status: String?
    var type: Int?
    var urlDocumentPinely: String?
    var urlDocumentUser1: String?
    var urlDocumentUser2: String?
    var dateSignature: Date?
    var DNIAgent: String?
    var nameAgent: String?
    var rejectReason: String?
    var legalCertificate: String?

    init(dict: [String: Any]) {
        self.id = dict.getInt("id")
        self.nameFile = dict.getString("name_file")
        self.status = dict.getString("status")
        self.type = dict.getInt("type")
        self.urlDocumentPinely = dict.getString("URL_document_pinely") ?? dict.getString("url_document_pinely")
        self.urlDocumentUser1 = dict.getString("URL_document_user_1") ?? dict.getString("url_document_user_1")
        self.urlDocumentUser2 = dict.getString("URL_document_user_2") ?? dict.getString("url_document_user_2")
        self.DNIAgent = dict.getString("DNI_agent")
        self.nameAgent = dict.getString("name_agent")
        if let strDateSignature = dict.getString("date_signature") {
            dateSignature = DateFormatter.iso8601GMT.date(from: strDateSignature)
        }
        self.rejectReason = dict.getString("reason") ?? dict.getString("reject-reason")
        self.legalCertificate = dict.getString("legal_certificate")
    }

    var bubbleColor: UIColor {
        guard let status = status else { return UIColor(hex: 0xB4B4B4)! }

        switch status {
        case "pending-send", "pending": return UIColor(hex: 0xFA1001)!
        case "waiting-review", "banned": return UIColor(hex: 0xFFD800)!
        case "rejected": return UIColor(hex: 0xFF0000)!
        case "approved": return UIColor(hex: 0x03E218)!
        default: return UIColor(hex: 0xB4B4B4)!
        }
    }
}
