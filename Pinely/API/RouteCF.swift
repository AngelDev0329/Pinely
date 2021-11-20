//
//  RouteCF.swift
//  Pinely
//

import Foundation

enum RouteCF: String, CaseIterable {
    case ipInformationUser = "https://wmnmx0jkgs.pinely.app"
    case getTokenUser = "get-token-user"
    case registerNewUser = "register-new-user"
    case contributionRequests = "contribution-requests"
    case usernameProfileCheck = "username-profile-check"
    case walletUserCheck = "https://viwunxhvi6.pinely.app"
    case getProfileInformation = "https://igxcdlyg4p.pinely.app"
    case lastMethodPayment = "last-method-payment"
    case checkPaymentMethods = "check-payment-methods"
    case addCreditCard = "https://plot5xugtj.pinely.app"
    case historicalSalesClient = "historical-sales-client"
    case deleteCreditCard = "delete-credit-card"
    case informationTransactionPurchase = "information-transaction-purchase"
    case buyTickets = "https://xknntwlkk4.pinely.app"
    case saveTokenDevice = "save_token_device"
    case checkRangeUser = "check-range-user"
    case addInterestLocal = "add_interest_local"
    case checkTicketsClient = "check-tickets-client"
    case checkInformationTicket = "check-information-ticket"
    case shoppingCartSave = "shopping_cart_save"
    case checkPromocode = "check-promocode"
    case photoLocal = "photo-local"
    case photoLocalContribution = "photo-local-contribution"
    case resumSalesQR = "resum-sales-qr"
    case showQRTicketsEvent = "show-qr-tickets-event"
    case countClientsInterestingPurchase = "count-clients-interesting-purchase"
    case checkQRInformation = "check-qr-information"
    case commentTicketScanner = "comment-ticket-scanner"
    case changeRangeToStaff = "change-range-to-staff"
    case checkDocumentsStaff = "check-documents-staff"
    case deletePhotoLocal = "delete-photo-local"
    case contractGenerator = "contract-generator"
    case contractSignatureCreator = "contract-signature-creator"
    case checkBankStaff = "check-bank-staff"
    case checkHowManyYouCanReject = "check-how-many-you-can-reject"
    case uploadDNIStaff = "upload-dni-staff"
    case checkLocalsStaff = "check-locals-staff"
    case documentUploader = "document-uploader"
    case createNewLocal = "create-new-local"
    case checkCountriesColaboration = "check-countries-colaboration"
    case createDocumentationStaff = "create-documentation-staff"
    case checkIfCanSell = "check-if-can-sell"
    case sendCopyEmail = "send-copy-email"
    case checkEmployeesList = "check-employees-list"
    case checkMicroblinkSerial = "check-microblink-serial"
    case checkMobileVerification = "check-mobile-verification"
    case sendSMSVerification = "send-sms-verification"
    case checkSMS = "check-SMS"
    case checkReferredURL = "check-referred-url"
    case checkReferal = "check-referal"
    case changeUsername = "change-username"
    case getReaderKey = "get-reader-key"
    case getLET = "get-let"
    case getSaleByPiReference = "get-sale-by-pi-reference"

    var url: String {
        if self == .getReaderKey {
            let rand = Int.random(in: 0..<1000000)
            return "\(RouteCF.baseUrl)/\(rawValue)?rand=\(rand)"
        } else if rawValue.hasPrefix("https://") {
            return rawValue
        } else {
            return "\(RouteCF.baseUrl)/\(rawValue)"
        }
    }

    static let baseUrl = "https://europe-west2-steadfast-canto-281114.cloudfunctions.net"
}
