//
//  CheckoutViewControll+STPApplePayContextDelegate.swift
//  Pinely
//

import UIKit
import Stripe
import PassKit
import FirebaseAnalytics

extension CheckoutViewController: STPApplePayContextDelegate {
    func applePayContext(_ context: STPApplePayContext,
                         didCreatePaymentMethod paymentMethod: STPPaymentMethod,
                         paymentInformation: PKPayment,
                         completion: @escaping STPIntentClientSecretCompletionBlock) {
        let paymentMethodId = paymentMethod.stripeId
        let idLocal = self.event!.idLocal!
        let idEvent = self.event!.id!
        let idTicket = self.ticket!.id!

        self.makePayment(idLocal, idEvent, idTicket, paymentMethodId, self.usePromocode?.code, completion)
    }

    func applePayContext(_ context: STPApplePayContext, didCompleteWith status: STPPaymentStatus, error: Error?) {
        switch status {
        case .success:
            // Payment succeeded, show a receipt view
            self.paymentEnded()

            // Analytics.logEvent("ecommerce_purchase", parameters: [:])
            let priceTicket = self.ticket?.priceTicket ?? 0
            let saleNumber = completedSale?.number ?? 0
            let gestionFee = self.ticket?.gestionFee ?? 0
            let item: [String: Any] = [
                "name_local": self.local?.localName ?? "",
                "name_event": self.event?.name ?? "",
                "name_ticket": self.ticket?.name ?? ""
            ]
            Analytics.logEvent("purchase", parameters: [
                "transaction_id": completedSale?.id ?? "",
                "value": Double(priceTicket * saleNumber + gestionFee) * 0.01,
                "currency": completedSale?.currency ?? "",
                "items": [ item ]
            ])

            self.notificationFeedbackGenerator.notificationOccurred(.success)
            AppSound.purchasedSuccessfully.play()

            let mainStoryboard = self.storyboard ?? UIStoryboard(name: "Main", bundle: nil)
            if let ticketQRVC = mainStoryboard.instantiateViewController(withIdentifier: "TicketQR")
                as? TicketQRViewController {
                ticketQRVC.local = self.local
                ticketQRVC.event = self.event
                ticketQRVC.ticket = self.ticket
                ticketQRVC.sale = completedSale
                ticketQRVC.requestRate = true

                guard let rootVC = mainStoryboard.instantiateInitialViewController(),
                      let window = (UIApplication.shared.delegate as? AppDelegate)?.window else {
                          self.goBack()
                          return
                      }

                window.rootViewController = rootVC
                rootVC.present(ticketQRVC, animated: true, completion: nil)
            }

        case .error:
            // Payment failed, show the error
            self.paymentEnded(force: true)
            self.show(error: error ?? NetworkError.apiError(error: "Apple Pay Error")) {
                self.loadingView?.stopAndRemove()
                self.loadingView = nil
            }

        case .userCancellation:
            // User cancelled the payment
            if PaymentProgress.current?.paymentStarted == true,
               loadingView != nil {
                // Payment is already in progress
                // Do nothing, wait while it's being processed
                self.applePayWasCancelled = true
            } else {
                // Payment was never started
                self.paymentEnded(force: true)
            }

        @unknown default:
            fatalError()
        }
    }
}
