//
//  CardType.swift
//  Pinely
//

import UIKit

// swiftlint:disable identifier_name
enum CardType {
    case apple
    case bitcoin
    case paypal
    case masterCard
    case visa
    case amex
    case jcb
    case dinersClub
    case discover
    case unionPay

    var image: UIImage {
        switch self {
        case .apple: return #imageLiteral(resourceName: "CardApple")
        case .bitcoin: return #imageLiteral(resourceName: "CardBitcoin")
        case .paypal: return #imageLiteral(resourceName: "CardPaypal")
        case .masterCard: return #imageLiteral(resourceName: "CardMastercard")
        case .visa: return #imageLiteral(resourceName: "CardVisa")
        case .amex: return #imageLiteral(resourceName: "CardAmex")
        case .jcb: return #imageLiteral(resourceName: "CardJcb")
        case .dinersClub: return #imageLiteral(resourceName: "CardDC")
        case .discover: return #imageLiteral(resourceName: "CardDiscover")
        case .unionPay: return #imageLiteral(resourceName: "CardUnionpay")
        }
    }

    var name: String {
        switch self {
        case .apple: return "Apple Pay"
        case .bitcoin: return "Bitcoin"
        case .paypal: return "PayPal"
        case .masterCard: return "MasterCard"
        case .visa: return "Visa"
        case .amex: return "American Express"
        case .jcb: return "JCB"
        case .dinersClub: return "Diners Club"
        case .discover: return "Discover"
        case .unionPay: return "UnionPay"
        }
    }

    static func getTypeByFirstNumbers(number: String) -> CardType? {
        if number.hasPrefix("4") {
            return CardType.visa
        } else if number.hasPrefix("22") || number.hasPrefix("23") || number.hasPrefix("24") || number.hasPrefix("25") ||
            number.hasPrefix("26") || number.hasPrefix("27") || number.hasPrefix("51") || number.hasPrefix("52") ||
            number.hasPrefix("53") || number.hasPrefix("54") || number.hasPrefix("55") {
            return CardType.masterCard
        } else if number.hasPrefix("30") || number.hasPrefix("36") || number.hasPrefix("38") || number.hasPrefix("39") {
            return CardType.dinersClub
        } else if number.hasPrefix("34") || number.hasPrefix("37") {
            return CardType.amex
        } else if number.hasPrefix("35") {
            return CardType.jcb
        } else if number.hasPrefix("60") {
            return CardType.discover
        } else if number.hasPrefix("62") {
            return CardType.unionPay
        } else {
            return nil
        }
    }
}
