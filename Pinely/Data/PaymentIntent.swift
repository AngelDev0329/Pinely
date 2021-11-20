//
//  PaymentIntent.swift
//  Pinely
//

import Foundation
import Stripe

struct PaymentIntent {
    var id: String
    var redirectUrl: URL?
    var status: String?
    var clientSecret: String?

    var reason: String?
    var sellerMessage: String?

    init?(dict: [String: Any]) {
        guard let idFromDict = dict.getString("id") else {
            return nil
        }

        self.id = idFromDict
        self.status = dict.getString("status")
        self.clientSecret = dict.getString("client_secret")
        if let nextAction = dict["next_action"] as? [String: Any],
           let useStripeSdk = nextAction["use_stripe_sdk"] as? [String: Any],
           let redirectUrlString = useStripeSdk.getString("stripe_js") {
            redirectUrl = URL(string: redirectUrlString)
        }
        if let charges = dict["charges"] as? [String: Any],
            let data = charges["data"] as? [Any],
            let data0 = data.first as? [String: Any],
            let outcome = data0["outcome"] as? [String: Any] {
            reason = outcome.getString("reason")
            sellerMessage = outcome.getString("seller_message")
        }
    }

    init(stripePaymentIntent: STPPaymentIntent) {
        self.id = stripePaymentIntent.stripeId
        self.redirectUrl = nil
        switch stripePaymentIntent.status {
        case .unknown: self.status = "unknown"
        case .requiresPaymentMethod: self.status = "requires_payment_method"
        case .requiresSource: self.status = "requires_source"
        case .requiresConfirmation: self.status = "requires_confirmation"
        case .requiresAction: self.status = "requires_action"
        case .requiresSourceAction: self.status = "requires_source_action"
        case .processing: self.status = "processing"
        case .succeeded: self.status = "succeeded"
        case .requiresCapture: self.status = "requires_capture"
        case .canceled: self.status = "canceled"
        }
        self.clientSecret = stripePaymentIntent.clientSecret
    }
}
