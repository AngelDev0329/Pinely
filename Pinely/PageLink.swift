//
//  PageLink.swift
//  Pinely
//

import Foundation

enum PageLink {
    case termsAndConditions
    case privacyPolicy
    case advise
    case eticalCode
    case environmentImpact
    case openSource

    func getUrlString(locale: String = "ES") -> String {
        switch self {
        case .termsAndConditions:
            return "https://pinely.app/legal/terms/\(locale.uppercased())/"

        case .privacyPolicy:
            return "https://pinely.app/legal/privacy/\(locale.uppercased())/"

        case .advise:
            return "https://pinely.app/legal/advice/\(locale.uppercased())/"

        case .eticalCode:
            return "https://storage.googleapis.com/pinely-documents/legal/etica/\(locale.uppercased())/codigo-etico.pdf"

        case .environmentImpact:
            return "https://climate.stripe.com/kIrWSZ"

        case .openSource:
            return "https://pinely.app/legal/open-source/\(locale.uppercased())/"
        }
    }

    func getUrl(locale: String = "ES") -> URL? {
        URL(string: getUrlString(locale: locale))
    }
}
