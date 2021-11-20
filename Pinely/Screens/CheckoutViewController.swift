//
//  CheckoutViewController.swift
//  Pinely
//

import UIKit
import Stripe
import PassKit
import FirebaseAuth
import SwiftEventBus
import FirebaseAnalytics
import FirebasePerformance

// swiftlint:disable type_body_length
// swiftlint:disable file_length
class CheckoutViewController: ViewController {
    @IBOutlet weak var ivCover: UIImageView!
    @IBOutlet weak var ivLogo: UIImageView!
    @IBOutlet weak var ivLogo2: UIImageView!

    @IBOutlet weak var lblTitleScreen: UILabel!
    @IBOutlet weak var lblTicketName: UILabel!
    @IBOutlet weak var lblTicketPrice: UILabel!
    @IBOutlet weak var lblTicketCount: UILabel!
    @IBOutlet weak var lblTicketLimit: UILabel!

    @IBOutlet weak var lblSalePace: UILabel!
    @IBOutlet weak var lblPromoCode: UILabel!

    @IBOutlet weak var lblSubPrice: UILabel!
    @IBOutlet weak var lblSubAmount: UILabel!
    @IBOutlet weak var lblSubCommission: UILabel!
    @IBOutlet weak var lblSubtotal: UILabel!
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var lblPayAmount: UILabel!
    @IBOutlet weak var lblWalletTitle: UILabel!
    @IBOutlet weak var lblWalletAmount: UILabel!
    @IBOutlet weak var lblPromoTitle: UILabel!
    @IBOutlet weak var lblPromoAmount: UILabel!

    @IBOutlet weak var lblResum: UILabel!
    @IBOutlet weak var lblPriceName: UILabel!
    @IBOutlet weak var lblSelectedEntriesName: UILabel!
    @IBOutlet weak var lblSubtotalName: UILabel!
    @IBOutlet weak var lblGestionName: UILabel!
    @IBOutlet weak var lblAmountPayName: UILabel!
    @IBOutlet weak var lblBannerText: UILabel!
    @IBOutlet weak var lblPaymentMethodName: UILabel!

    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnBackFront: UIButton!
    @IBOutlet weak var btnShareFront: UIButton!
    @IBOutlet weak var btnPay: UIButton!

    @IBOutlet weak var ivCardFace: UIImageView!
    @IBOutlet weak var lblCardHidden: UILabel!
    @IBOutlet weak var lblCardNumber: UILabel!

    @IBOutlet weak var aiLoadingPaymentMethods: UIActivityIndicatorView!
    @IBOutlet weak var vPaymentMethod: UIView!

    @IBOutlet weak var lcPayAmountTop: NSLayoutConstraint!
    @IBOutlet weak var lcPromoTop: NSLayoutConstraint!

    var place: Place?
    var local: Local?
    var event: Event!
    var ticket: Ticket!
    var ticketCount: Int {
        ticket?.amount ?? 1
    }

    var fullGestion: Int = 0
    var fullPrice: Int = 0

    var walletBalance: Wallet = Wallet()
    var amountToPay: Int = 0
    var amountWallet: Int = 0
    var amountPromo: Int = 0
    var usePromocode: Promocode?

    var selectedPaymentMethod: Card?
    var paymentMethods: [Card] = []

    var completedSale: Sale?
    var applePayWasCancelled = false

    var paymentInProgress = false
    var isActive = true

    var upid = ""

    var loadingView: LoadingView?

    var trace: Trace?

    var userToken: String?

    let translation = AppDelegate.translation

    let notificationFeedbackGenerator = UINotificationFeedbackGenerator()

    private func loadAmountPurchasingPeople() {
        API.shared.getAmountPurchasingTicket(eventId: event.id ?? 0) { [self] (amount, _) in
            if let amount = amount,
               amount > 0 {
                if amount == 1 {
                    self.lblSalePace.text = "🎟️  \(amount) " +
                    (self.translation?.getString("checkout_banner_1_person") ??
                     "persona está comprando esta entrada")
                } else {
                    self.lblSalePace.text = "🎟️  \(amount) " +
                    (self.translation?.getString("checkout_banner_more_persons") ??
                     "personas están comprando estas entradas")
                }
            } else {
                self.lblSalePace.text = "🎟️  1 " +
                (self.translation?.getString("checkout_banner_1_person") ??
                 "persona está comprando esta entrada")
            }
        }
    }

    private func showPictures() {
        if let thumbUrl = local?.thumb ?? place?.thumbUrl,
           let url = URL(string: thumbUrl) {
            ivCover.kf.setImage(with: url)
        }
        if let avatarUrl = local?.avatar ?? place?.avatarUrl,
           let url = URL(string: avatarUrl) {
            ivLogo.kf.setImage(with: url)
        }
        if let thumbUrl = ticket.urlThumb,
           let url = URL(string: thumbUrl) {
            ivLogo2.kf.setImage(with: url)
        }
    }

    private func showTicketName() {
        let ticketName = ticket.name ?? ""
        let ticketNameComponents = ticketName.components(separatedBy: " (")
        if ticketNameComponents.count == 2 {
            if ticketNameComponents[0].count < 30, ticketNameComponents[1].count < 30 {
                lblTicketName.text = "\(ticketNameComponents[0])\n(\(ticketNameComponents[1])"
            } else {
                lblTicketName.text = ticketName
            }
        } else {
            lblTicketName.text = ticketName
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        showPictures()

        let ticketPrice = ticket.priceTicket ?? 0
        let gestionFee = ticket.gestionFee ?? 0
        fullPrice = (ticketPrice + gestionFee) * ticket.amount
        fullGestion = gestionFee * ticket.amount
        amountToPay = fullPrice

        lblSubtotal.text = (fullPrice - fullGestion).toPrice()

        showTicketName()

        lblTitleScreen.text = translation?.getString("checkout_title") ?? "DETALLES DE TU COMPRA"

        lblTicketPrice.text = (translation?.getString("checkout_price") ?? "Precio:") + " " + (ticket.priceTicket ?? 0).toPrice()
        if ticket.amount == 1 {
            lblTicketCount.text = ticket.amount.toString() + " " + (translation?.getString("checkout_1_ticket") ?? "entrada")
        } else {
            lblTicketCount.text = ticket.amount.toString() + " " + (translation?.getString("checkout_more_tickets") ?? "entradas")
        }
        lblTicketLimit.text = (translation?.getString("checkout_hour_limit") ?? "Limite: ") + " " + ticket.getHourLimitString()

        lblSubPrice.text = (ticket.priceTicket ?? 0).toPrice()
        lblSubAmount.text = "\(ticket.amount)"
        lblSubCommission.text = fullGestion.toPrice()
        lblTotal.text = amountToPay.toPrice()

        // lblPayAmount.text = "Pagar " + amountToPay.toPrice()
        lblPayAmount.text = "Un momento..."
        btnPay.isEnabled = false

        loadWallet()
        loadPaymentMethods()

        lblResum.text = translation?.getString("checkout_resum")
        lblPriceName.text = translation?.getString("checkout_unitary_price")
        lblSelectedEntriesName.text = translation?.getString("checkout_tickets_choosed")
        lblSubtotalName.text = translation?.getString("checkout_subtotal")
        lblGestionName.text = translation?.getString("checkout_gestionfees_applied")
        lblAmountPayName.text = translation?.getString("checkout_amount_pay")

        lblPaymentMethodName.text = translation?.getString("checkout_payment_method")
        lblPromoTitle.text = translation?.getString("checkout_promocode_applied")
        lblPromoCode.text = translation?.getString("checkout_exchange_promocode")

        if let attributedText = translation?.getString("checkout_banner_text")!.attributedHTMLString {
            let coloredAttributedText = NSMutableAttributedString(attributedString: attributedText)
            coloredAttributedText.addAttributes([
                .foregroundColor: UIColor(named: "MainForegroundColor")!
            ], range: NSRange(location: 0, length: coloredAttributedText.length))
            lblBannerText.attributedText = coloredAttributedText
        }

        loadAmountPurchasingPeople()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        SwiftEventBus.onMainThread(self, name: "applicationDidBecomeActive") { (_) in
            self.isActive = true

            if self.actionWhenActive != nil {
                self.handlePaymentError(self.actionWhenActive?.paymentIntent, self.actionWhenActive?.error, self.actionWhenActive?.completion)
                self.actionWhenActive = nil
            }
        }

        SwiftEventBus.onMainThread(self, name: "applicationWillResignActive") { (_) in
            self.isActive = false
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        SwiftEventBus.unregister(self, name: "applicationDidBecomeActive")
        SwiftEventBus.unregister(self, name: "applicationWillResignActive")
    }

    deinit {
        SwiftEventBus.unregister(self, name: "authChanged")
        SwiftEventBus.unregister(self)
    }

    private func loadWallet() {
        API.shared.getWalletAmount { (amount, _) in
            self.btnPay.isEnabled = true

            guard let amount = amount,
                  !self.paymentInProgress
            else { return }

            self.walletBalance = amount
            self.showDiscounts()
        }
    }

    private func showDiscounts() {
        // Calculations
        amountPromo = 0

        if let promocode = usePromocode,
            promocode.quantity > 0 {
            if fullPrice - promocode.quantity > fullGestion {
                amountToPay = fullPrice - promocode.quantity
                amountPromo = promocode.quantity
            } else {
                amountToPay = fullGestion
                amountPromo = fullPrice - amountToPay
            }

        } else {
            amountToPay = fullPrice
        }

        if walletBalance.amount > 0 {
            if walletBalance.amount > amountToPay - fullGestion {
                amountWallet = amountToPay - fullGestion
            } else {
                amountWallet = walletBalance.amount
            }

            amountToPay -= amountWallet
        } else {
            amountWallet = 0
        }

        // Layout
        var y: CGFloat = 16

        if amountPromo > 0 {
            y += 30
            lblPromoAmount.text = "-" + amountPromo.toPrice()
            lblPromoTitle.isHidden = false
            lblPromoAmount.isHidden = false
        } else {
            lblPromoTitle.isHidden = true
            lblPromoAmount.isHidden = true
        }

        lcPromoTop.constant = y

        if amountWallet > 0 {
            y += 30
            lblWalletAmount.text = "-" + amountWallet.toPrice()
            lblWalletTitle.isHidden = false
            lblWalletAmount.isHidden = false
        } else {
            lblWalletTitle.isHidden = true
            lblWalletAmount.isHidden = true
        }

        lcPayAmountTop.constant = y

//        #if targetEnvironment(simulator)
//        amountToPay = 50
//        #endif

        lblTotal.text = amountToPay.toPrice()

        lblPayAmount.text = (self.translation?.getString("checkout_pay_button") ?? "Pagar") + " " + amountToPay.toPrice()

        view.layoutIfNeeded()
    }

    private func loadPaymentMethods() {
        API.shared.getLastMethodPayment { (lastPaymentMethod, _) in
            self.selectedPaymentMethod = lastPaymentMethod
            self.showPaymentMethod()
        }
    }

    private func showPaymentMethod() {
        if selectedPaymentMethod == nil {
            selectedPaymentMethod = Card.apple
        }

        ivCardFace.image = selectedPaymentMethod!.type?.image
        if let cardType = selectedPaymentMethod!.type {
            switch cardType {
            case .visa, .masterCard, .amex, .dinersClub, .discover, .jcb, .unionPay:
                lblCardHidden.text = "•••• "
                lblCardNumber.text = selectedPaymentMethod!.last4 ?? ""

            case .apple:
                lblCardHidden.text = ""
                lblCardNumber.text = "Apple Pay"

            case .bitcoin:
                lblCardHidden.text = ""
                lblCardNumber.text = "Bitcoin"

            case .paypal:
                lblCardHidden.text = ""
                lblCardNumber.text = "PayPal"
            }
        } else {
            lblCardHidden.text = ""
            lblCardNumber.text = selectedPaymentMethod!.last4 ?? ""
        }

        aiLoadingPaymentMethods.stopAnimating()
        vPaymentMethod.isHidden = false
    }

    @IBAction func share() {
        if paymentInProgress {
            return
        }

        guard let roomId = event.idLocal
            else { return }

        let roomName = local?.localName ?? place?.name ?? ""

        guard let link = ShareLink.room(roomId: roomId).url else {
            return
        }
        generate(link: link, title: nil, descriptionText: nil,
                 imageURL: nil) { [weak self] (url) in
            guard let self = self else {
                return
            }

            let text = self.createShareText(
                stringId: "share.place.text", eventName: nil,
                roomName: roomName, url: url)

            self.shareText(text, sourceView: self.btnShare)
        }
    }

    @IBAction func addPromoCode() {
        if paymentInProgress {
            return
        }

        UIDevice.vibrate()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if self.usePromocode == nil {
                
                var strTitle: String?
                var strDescription: String?
                var strSend: String?
                var strCancel: String?

                let translation = AppDelegate.translation
                
                strTitle = translation?.getString("exchange_promo_title") ?? "Código promocional"
                strDescription = translation?.getString("exchange_promo_description") ?? "Introduce un código promocional para aplicarlo en esta compra"
                strCancel = translation?.getString("exchange_promo_button1") ?? "Cancelar"
                strSend = translation?.getString("exchange_promo_button2") ?? "Aplicar"
                
                
                let alert = UIAlertController(
                    title: strTitle,
                    message: strDescription,
                    preferredStyle: .alert)
                alert.addTextField { (textField: UITextField!) -> Void in
                    textField.returnKeyType = .done
                }
                alert.addAction(UIAlertAction(title: strSend, style: .cancel) { (_) in
                    guard
                        let firstField = alert.textFields?.first,
                        let code = firstField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                        !code.isEmpty
                        else { return }
                    self.apply(promoCodeString: code)
                })
                alert.addAction(UIAlertAction(title: strCancel, style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(
                    title: "Cancelar código",
                    message: "Si cancelas este código promocional no te podrás beneficiar del descuento ¿Estás seguro?",
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancelar código", style: .destructive) { (_) in
                    self.lblPromoCode.text = "Tengo un código promocional"
                    self.usePromocode = nil
                    self.showDiscounts()
                })
                alert.addAction(UIAlertAction(title: "Atrás", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    fileprivate func showPromoApplied() {
        let alert = UIAlertController(title: "alert.promoCode".localized,
                                      message: "alert.correctPromoCode".localized,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "button.accept".localized, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    fileprivate func promoCodeApplied(promocode: Promocode, promoCodeString: String) {
        self.usePromocode = promocode
        self.lblPromoCode.text = promocode.code ?? promoCodeString
        self.showDiscounts()

        self.showPromoApplied()
    }

    private func showPromocodeError() {
        let alert = UIAlertController(title: "alert.ops".localized,
                                      message: "alert.incorrectPromoCode".localized,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    private func apply(promoCodeString: String) {
        guard let activeTicket = self.ticket else { return }

        let progressView = BlurryLoadingView.showAndStart()
        API.shared.checkPromocode(promocode: promoCodeString, localId: event.idLocal ?? 0,
                                  eventId: event.id ?? 0, ticketId: ticket.id ?? 0) { [weak self] (promocode, error) in
            if let error = error {
                progressView.stopAndHide()
                self?.show(error: error)
                return
            }

            guard let promocode = promocode else {
                progressView.stopAndHide()
                self?.showPromocodeError()
                return
            }

            if !promocode.validForAllLocals && !promocode.validForAllEvents &&
                !promocode.validForAllTickets && promocode.idTicket != activeTicket.id {
                progressView.stopAndHide()
                self?.showError("error.promoCodeIncorrectForEntry".localized, delegate: {
                    // No action required
                }, title: "alert.ops".localized)
                return
            }

            if promocode.onlyFirstPurchase {
                API.shared.checkPromocodeUsed(promocode: promoCodeString) { [weak self] (used, error) in
                    progressView.stopAndHide()

                    if let error = error {
                        self?.show(error: error)
                        return
                    }

                    if used != false {
                        self?.showError("error.promoCodeOnlyFirstPurchase".localized)
                    } else {
                        self?.promoCodeApplied(promocode: promocode, promoCodeString: promoCodeString)
                    }
                }
            } else {
                progressView.stopAndHide()
                self?.promoCodeApplied(promocode: promocode, promoCodeString: promoCodeString)
            }
        }
    }

    @IBAction func changePaymentMethod() {
        if paymentInProgress {
            return
        }

        UIDevice.vibrate()

        if paymentMethods.isEmpty {
            let blurryLoadingView = BlurryLoadingView.showAndStart()
            API.shared.getPaymentMethods { paymentMethods, error in
                blurryLoadingView.stopAndHide()
                if let error = error {
                    self.showError(error.localizedDescription)
                } else {
                    self.paymentMethods = paymentMethods
                    self.performSegue(withIdentifier: "PaymentMethods", sender: self)
                }
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.performSegue(withIdentifier: "PaymentMethods", sender: self)
            }
        }
    }

    override func goBack() {
        if !paymentInProgress {
            super.goBack()
        }
    }

    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map { _ in letters.randomElement()! })
    }

    func generateUpid() {
        upid = randomString(length: 64)
    }

    @IBAction func pay() {
        UIDevice.vibrate()

        if !paymentInProgress {
            startPayment()
        }
    }

    private func startPayment() {
        paymentInProgress = true

        self.lblPayAmount.text = (self.translation?.getString("processing_payment_text") ?? "Procesando, un momento...")

        // Check if user information is ready
        API.shared.loadUserInfo(force: false) { (profile, error) in
            if let error = error {
                self.paymentEnded(force: true)
                self.paymentInProgress = false
                self.show(error: error)
                return
            }

            let mobilePhone = profile?.mobilePhone ?? ""
            if mobilePhone.isEmpty {
                // Finish registration
                SwiftEventBus.onMainThread(self, name: "authChanged") { (_) in
                    SwiftEventBus.unregister(self, name: "authChanged")

                    if Auth.auth().currentUser != nil {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.startPayment()
                        }
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.paymentEnded(force: true)
                    self.paymentInProgress = false
                }
                self.performSegue(withIdentifier: "FinishRegistration", sender: self)
                return
            }

            // Good to go
            self.generateUpid()
            self.applePayWasCancelled = false

            if #available(iOS 13.0, *) {
                self.isModalInPresentation = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.doPay()
            }
        }
    }

    func paymentEnded(force: Bool = false) {
        if !isActive && !force {
            return
        }

        PaymentProgress.reset()
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = false
        }
        lblPayAmount.text = "Pagar " + amountToPay.toPrice()
        self.paymentInProgress = false
        self.loadingView?.stopAndRemove()
        self.loadingView = nil
    }

    struct ActionWhenActive {
        var paymentIntent: PaymentIntent?
        var error: Error?
        var completion: STPIntentClientSecretCompletionBlock?
    }

    var actionWhenActive: ActionWhenActive?

    private func showTicketQR(_ sale: Sale) {
        let priceTicket = self.ticket?.priceTicket ?? 0
        let saleNumber = sale.number ?? 0
        let gestionFee = self.ticket?.gestionFee ?? 0
        let item = [
            "name_local": self.local?.localName ?? "",
            "name_event": self.event?.name ?? "",
            "name_ticket": self.ticket?.name ?? ""
        ]
        Analytics.logEvent("purchase", parameters: [
            "transaction_id": sale.id ?? "",
            "value": Double(priceTicket * saleNumber + gestionFee) * 0.01,
            "currency": sale.currency ?? "",
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
            ticketQRVC.sale = sale

            guard let rootVC = mainStoryboard.instantiateInitialViewController(),
                  let window = (UIApplication.shared.delegate as? AppDelegate)?.window else {
                      self.goBack()
                      return
                  }

            window.rootViewController = rootVC
            rootVC.present(ticketQRVC, animated: true, completion: nil)
        }
    }

    private func saleReceived(sale: Sale, paymentIntent: PaymentIntent?,
                              completion: STPIntentClientSecretCompletionBlock?) {
        if let completion = completion {
            self.completedSale = sale
            completion(paymentIntent?.clientSecret, nil)
        } else {
            self.showTicketQR(sale)
        }
    }

    private func handlePaymentError(_ paymentIntent: PaymentIntent?, _ error: Error?,
                                    _ completion: STPIntentClientSecretCompletionBlock? = nil) {
        self.loadingView?.stopAndRemove()
        self.loadingView = nil

        if !isActive {
            // Wait for app to come back
            if let completion = completion {
                actionWhenActive = ActionWhenActive(paymentIntent: paymentIntent, error: nil, completion: completion)
            } else {
                var newError: Error? = error
                if let error = error,
                    let networkError = error as? NetworkError {
                    switch networkError {
                    case .serverError:
                        newError = NetworkError.apiError(error: "error.cardRejectedByBank".localized)

                    default:
                        break
                    }
                }
                actionWhenActive = ActionWhenActive(paymentIntent: paymentIntent, error: newError, completion: nil)
            }
            return
        }

        // Verify upid
        self.notificationFeedbackGenerator.prepare()
        API.shared.getSaleByUpid(upid: self.upid) { (sale, _) in
            self.paymentEnded()
            if let sale = sale {
                self.saleReceived(sale: sale, paymentIntent: paymentIntent, completion: completion)
            } else {
                if let completion = completion {
                    completion(nil, error ?? NetworkError.apiError(error: NetworkError.defaultPaymentError))
                } else {
                    self.show(error: error ?? NetworkError.apiError(error: NetworkError.defaultPaymentError)) {
                        self.loadingView?.stopAndRemove()
                        self.loadingView = nil
                    }
                }
            }
        }
    }

    fileprivate func verifyIfPaymentConfirmed(_ idLocal: Int, _ idEvent: Int,
                                              _ idTicket: Int, _ paymentMethodId: String,
                                              _ paymentIntent: PaymentIntent, _ promoCode: String?,
                                              _ attempt: Int, _ completion: STPIntentClientSecretCompletionBlock? = nil) {
        self.notificationFeedbackGenerator.prepare()

        let args = PaymentArguments(
            upid: self.upid, idLocal: idLocal, idEvent: idEvent, idTicket: idTicket,
            ticketNumber: self.ticketCount, amount: self.amountToPay, paymentMethod: paymentMethodId,
            amountWallet: self.amountWallet, amountPromo: self.amountPromo, promoCode: promoCode)
        API.shared.completePayment(args, paymentIntent: paymentIntent.id) { (sale, error) in
            if let sale = sale {
                // Successful purchase
                self.paymentEnded()

                if let completion = completion {
                    self.completedSale = sale
                    completion(paymentIntent.clientSecret, nil)
                } else {
                    self.showTicketQR(sale)
                }
            } else {
                if attempt < 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.verifyIfPaymentConfirmed(idLocal, idEvent, idTicket, paymentMethodId,
                                                      paymentIntent, promoCode, attempt + 1, completion)
                    }
                } else {
                    self.handlePaymentError(paymentIntent, error, completion)
                }
            }
        }
    }

    fileprivate func run3DSecure(
        _ idLocal: Int, _ idEvent: Int,
        _ idTicket: Int, _ paymentMethodId: String,
        _ paymentIntent: PaymentIntent, _ promoCode: String?,
        _ completion: STPIntentClientSecretCompletionBlock? = nil) {
        // 3D-secure
        if paymentIntent.redirectUrl == nil {
            // 3DSv2
            let customizationSettings = STPThreeDSCustomizationSettings()
            customizationSettings.uiCustomization = STPThreeDSUICustomization.defaultSettings()
            customizationSettings.authenticationTimeout = 5
            STPPaymentHandler.shared().threeDSCustomizationSettings = customizationSettings
            let paymentParams = STPPaymentIntentParams(clientSecret: paymentIntent.clientSecret ?? "")
            STPPaymentHandler.shared().confirmPayment(paymentParams, with: self) { (status, intent, error) in
                if let error = error {
                    self.paymentEnded()
                    self.showError(error.localizedDescription)
                    return
                }

                switch status {
                case .succeeded:
                    var newPaymentIntent = paymentIntent
                    if let intent = intent {
                        newPaymentIntent = PaymentIntent(stripePaymentIntent: intent)
                    }
                    self.verifyIfPaymentConfirmed(
                        idLocal, idEvent, idTicket, paymentMethodId,
                        newPaymentIntent, promoCode, 0, completion)

                case .failed:
                    self.paymentEnded()
                    self.showError("Payment was not verified")

                case .canceled:
                    break
                }
            }
        } else {
            // 3DSv1
            SwiftEventBus.onMainThread(self, name: "paymentEnded") { (_) in
                SwiftEventBus.unregister(self, name: "paymentEnded")

                self.verifyIfPaymentConfirmed(
                    idLocal, idEvent, idTicket, paymentMethodId,
                    paymentIntent, promoCode, 0, completion)
            }
            self.performSegue(withIdentifier: "Payment3DSecure", sender: paymentIntent)
        }
    }

    fileprivate func processPayError(
        _ networkError: NetworkError,
        _ completion: STPIntentClientSecretCompletionBlock? = nil) {
        switch networkError {
        case .phoneNotVerified:
            self.paymentEnded()
            if let completion = completion {
                completion(nil, nil)
            }
            self.verifyMobileNumber()

        case .emailNotVerified:
            self.paymentEnded()
            if let completion = completion {
                completion(nil, nil)
            }
            self.verifyFirebaseUserEmail()

        default:
            if let completion = completion {
                completion(nil, networkError)
            } else {
                self.handlePaymentError(nil, networkError, completion)
            }
        }
    }

    func makePayment(_ idLocal: Int, _ idEvent: Int,
                     _ idTicket: Int, _ paymentMethodId: String,
                     _ promoCode: String?, _ completion: STPIntentClientSecretCompletionBlock? = nil) {
        loadingView = LoadingView.showAndRun(text: "Estamos comprando tus\nentradas, un momento...",
                                             viewController: self)

        PaymentProgress.current = PaymentProgress(upid: self.upid, roomId: idLocal,
                                                  eventId: idEvent, ticketId: idTicket)
        PaymentProgress.current?.paymentMethodId = paymentMethodId
        PaymentProgress.current?.promoCode = promoCode
        PaymentProgress.current?.amountToPay = amountToPay
        PaymentProgress.current?.amountWallet = amountWallet
        PaymentProgress.current?.amountPromo = amountPromo
        PaymentProgress.current?.ticketCount = ticketCount
        if completion != nil {
            PaymentProgress.current?.isApplePay = true
        }
        PaymentProgress.current?.paymentStarted = true
        PaymentProgress.current?.save()
        let args = PaymentArguments(
            upid: self.upid, idLocal: idLocal, idEvent: idEvent, idTicket: idTicket,
            ticketNumber: ticketCount, amount: amountToPay, paymentMethod: paymentMethodId,
            amountWallet: amountWallet, amountPromo: amountPromo)
        API.shared.pay(args) { (sale, paymentIntent, error) in
            if let sale = sale {
                self.notificationFeedbackGenerator.prepare()

                // Successful purchase
                self.paymentEnded()

                if let completion = completion,
                    !self.applePayWasCancelled {
                    self.completedSale = sale
                    completion(paymentIntent?.clientSecret, nil)
                } else {
                    self.showTicketQR(sale)
                }
            } else if let paymentIntent = paymentIntent {
                self.run3DSecure(idLocal, idEvent, idTicket, paymentMethodId,
                                 paymentIntent, promoCode, completion)
            } else if let networkError = error as? NetworkError {
                self.processPayError(networkError, completion)
            } else {
                // Generic error
                if let completion = completion {
                    completion(nil, error)
                } else {
                    self.handlePaymentError(nil, error, completion)
                }
            }
        }
    }

    private func checkWalletChanged(delegate: @escaping (_ changed: Bool, _ error: Error?) -> Void) {
        if amountWallet == 0 {
            // Skip
            delegate(false, nil)
        } else {
            // Check
            API.shared.getWalletAmount { (newAmount, error) in
                if let error = error {
                    delegate(false, error)
                } else {
                    if let newAmount = newAmount,
                       newAmount.amount != self.walletBalance.amount {
                        self.walletBalance = newAmount
                        self.showDiscounts()
                        delegate(true, nil)
                    } else {
                        delegate(false, nil)
                    }
                }
            }
        }
    }

    private func doPay() {
        guard let idLocal = self.event?.idLocal else {
            self.paymentEnded()
            self.showError("Internal error. Room id is missing")
            return
        }

        guard let idEvent = self.event.id else {
            self.paymentEnded()
            self.showError("Internal error. Event id is missing")
            return
        }

        guard let idTicket = self.ticket.id else {
            self.paymentEnded()
            self.showError("Internal error. Ticket id is missing")
            return
        }

        self.checkWalletChanged { (changed, error) in
            if let error = error {
                self.paymentEnded()
                self.show(error: error)
                return
            }

            if changed {
                self.paymentEnded()
                self.showError("El saldo de tu monedero ha cambiado justo cuando estabas haciendo esta compra, inténtalo de nuevo")
                return
            }

            if self.selectedPaymentMethod?.type == CardType.apple {
                let merchantIdentifier = "merchant.pinely"
                let paymentRequest = StripeAPI.paymentRequest(
                    withMerchantIdentifier: merchantIdentifier, country: "ES",
                    currency: self.ticket.currency ?? "EUR")

                // Configure the line items on the payment request
                // let amount = NSDecimalNumber(value: self.amountToPay.centsToEuros() ?? 0.0)
                let amount = NSDecimalNumber(string: String(format: "%d.%02d", self.amountToPay / 100, self.amountToPay % 100))
                paymentRequest.paymentSummaryItems = [
                    // The final line should represent your company;
                    // it'll be prepended with the word "Pay" (i.e. "Pay iHats, Inc $50")
                    PKPaymentSummaryItem(label: "Pinely", amount: amount)
                ]

                paymentRequest.requiredBillingContactFields = Set()
                paymentRequest.requiredShippingContactFields = Set()

                // Initialize an STPApplePayContext instance
                if let applePayContext = STPApplePayContext(paymentRequest: paymentRequest, delegate: self) {
                    applePayContext.presentApplePay(from: UIApplication.shared.keyWindow)
                } else {
                    // There is a problem with your Apple Pay configuration
                    self.showError("Apple Pay is not available")
                }
                return
            }

            guard let paymentMethodId = self.selectedPaymentMethod?.paymentMethod else {
                self.paymentEnded()
                self.showError("Please select payment method")
                return
            }

            self.makePayment(idLocal, idEvent, idTicket, paymentMethodId, self.usePromocode?.code)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let myPaymentMethodsVC = segue.destination as? MyPaymentMethodsViewController {
            myPaymentMethodsVC.delegate = self
            myPaymentMethodsVC.cards = self.paymentMethods
        } else if let payment3DSecureVC = segue.destination as? Payment3DSecureViewController {
            payment3DSecureVC.paymentIntent = sender as? PaymentIntent
        }
    }

    override var preferredStatusBarStyleInternal: UIStatusBarStyle {
        .lightContent
    }
}

extension CheckoutViewController: STPAuthenticationContext {
    func authenticationPresentingViewController() -> UIViewController {
        self
    }
}

extension CheckoutViewController: PaymentMethodSelectionDelegate {
    func paymentMethodSelected(_ paymentMethod: Card) {
        self.selectedPaymentMethod = paymentMethod
        self.showPaymentMethod()
    }
}
