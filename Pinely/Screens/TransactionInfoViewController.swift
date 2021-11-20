//
//  TransactionInfoViewController.swift
//  Pinely
//

import UIKit
import MapKit
import Alamofire
import FirebaseRemoteConfig

// swiftlint:disable type_body_length
class TransactionInfoViewController: ViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblSubtotal: UILabel!
    @IBOutlet weak var lblPromoCodeTitle: UILabel!
    @IBOutlet weak var lblPromoCode: UILabel!
    @IBOutlet weak var lblUsedWalletTitle: UILabel!
    @IBOutlet weak var lblUsedWallet: UILabel!
    @IBOutlet weak var lcUsedWalletTop: NSLayoutConstraint!
    @IBOutlet weak var lblFees: UILabel!
    @IBOutlet weak var lcFeesTop: NSLayoutConstraint!
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var lblPaymentMethod: UILabel!
    @IBOutlet weak var ivPaymentMethod: UIImageView!

    @IBOutlet weak var vRefund: UIView!
    @IBOutlet weak var lblRefundedEntries: UILabel!
    @IBOutlet weak var lblRefundedAmount: UILabel!
    @IBOutlet weak var lblRefundMethod: UILabel!

    @IBOutlet weak var vProblemContainer: UIView!

    @IBOutlet weak var lcMapTop: NSLayoutConstraint!
    @IBOutlet weak var lcMapHeight: NSLayoutConstraint!
    @IBOutlet weak var vMapContainer: UIView!
    @IBOutlet weak var mkMapView: MKMapView!

    @IBOutlet weak var vFactura: UIView!
    @IBOutlet weak var ivFactura: UIImageView!
    @IBOutlet weak var aiFacturaLoading: UIActivityIndicatorView!
    @IBOutlet weak var lcFacturaHeight: NSLayoutConstraint!

    @IBOutlet weak var vInfoBox: UIView!
    @IBOutlet weak var lblInfoTitle: UILabel!
    @IBOutlet weak var lblInfoDescription: UILabel!

    var purchase: Purchase!
    var transactionInfo: TransactionInfo?
    var pdfData: Data?
    var hasValidPdf = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadData()
    }

    private func loadData() {
        guard let piReference = purchase.payment else {
            self.showError("No transaction info")
            self.goBack()
            return
        }

        API.shared.getInformationTransactionPurchase(piReference: piReference) { (transactionInfo, error) in
            if let error = error {
                self.show(error: error) {
                    self.goBack()
                }
                return
            }

            self.transactionInfo = transactionInfo
            self.showTransaction()
        }
    }

    fileprivate func showPaymentMethod(_ transactionInfo: TransactionInfo) {
        if let brand = transactionInfo.brand {
            var brandText = ""
            var brandProcessed = brand.lowercased()
            brandProcessed.removeAll(where: { $0 == " "})
            switch brandProcessed {
            case "visa": ivPaymentMethod.image = #imageLiteral(resourceName: "CardVisa")
            case "mastercard": ivPaymentMethod.image = #imageLiteral(resourceName: "CardMastercard")
            case "dc", "dinersclab": ivPaymentMethod.image = #imageLiteral(resourceName: "CardDC")
            case "unionpay": ivPaymentMethod.image = #imageLiteral(resourceName: "CardUnionpay")
            case "discover": ivPaymentMethod.image = #imageLiteral(resourceName: "CardDiscover")
            case "jcb": ivPaymentMethod.image = #imageLiteral(resourceName: "CardJcb")
            case "amex", "americanexpress": ivPaymentMethod.image = #imageLiteral(resourceName: "CardAmex")
            default:
                ivPaymentMethod.image = nil
                brandText = brand
            }
            if let last4 = transactionInfo.last4 {
                lblPaymentMethod.text = "\(brandText) ●●●● \(last4)"
            } else {
                lblPaymentMethod.text = brandText
            }
        } else {
            ivPaymentMethod.image = #imageLiteral(resourceName: "CardApple")
            lblPaymentMethod.text = "Apple Pay"
        }
    }

    fileprivate func showRefund(_ transactionInfo: TransactionInfo) {
        if let refund = transactionInfo.refunds.first {
            vRefund.isHidden = false
            lblRefundedEntries.text = "\(refund.ticketsRefunds ?? 0)"
            lblRefundedAmount.text = "+" + (refund.quantityRefund ?? 0).toPrice()
            lblRefundMethod.text = refund.methodRefund?.capitalized ?? ""
            vProblemContainer.isHidden = true

            lcMapTop.constant = 119
        } else {
            vProblemContainer.isHidden = false

            lcMapTop.constant = 14
        }
    }

    fileprivate func showMap(_ transactionInfo: TransactionInfo) {
        var latitude: Double?
        var longitude: Double?
        if let ubication = transactionInfo.ubication,
           ubication.contains(",") {
            let coordsArr = ubication.components(separatedBy: ",")
            if coordsArr.count == 2 {
                latitude = Double(coordsArr[0].trimmingCharacters(in: .whitespacesAndNewlines))
                longitude = Double(coordsArr[1].trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }

        if let latitude = latitude,
           let longitude = longitude {
            // Show map
            vMapContainer.isHidden = false
            lcMapHeight.constant = 180

            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let viewRegion = MKCoordinateRegion(center: location, latitudinalMeters: 200000, longitudinalMeters: 200000)
            mkMapView.setRegion(viewRegion, animated: false)

            mkMapView.removeAnnotations(mkMapView.annotations)
            mkMapView.addAnnotation(InfoMapAnnotation(title: "", coordinate: location))
        } else {
            // Hide map
            vMapContainer.isHidden = true
            lcMapHeight.constant = 1
        }
    }

    fileprivate func showInvoice(_ transactionInfo: TransactionInfo) {
        if let facturaUrl = transactionInfo.invoiceUrl,
           let url = URL(string: facturaUrl) {
            aiFacturaLoading.startAnimating()
            AF.request(url).responseData { (response) in
                self.aiFacturaLoading.stopAnimating()

                guard let pdfData = response.data else {
                    return
                }
                self.pdfData = pdfData

                let fileUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("invoice.pdf")

                do {
                    try pdfData.write(to: fileUrl)
                    if self.ivFactura.fromPdf(
                        fileUrl: fileUrl, page: 1,
                        width: UIScreen.main.scale * 100, height: UIScreen.main.scale * 141) {
                        self.hasValidPdf = true
                    }
                } catch {

                }
            }
            vFactura.isHidden = false
            lcFacturaHeight.constant = 200
        } else {
            vFactura.isHidden = true
            lcFacturaHeight.constant = 1
        }
    }

    private func showTransaction() {
        guard let transactionInfo = transactionInfo else {
            return
        }

        let transactionInfoId = transactionInfo.id ?? 0
        lblTitle.text = "Pedido: \(transactionInfoId)"
        lblPrice.text = transactionInfo.priceTicket.toPrice()
        lblAmount.text = "\(transactionInfo.ticketsNumber)"
        lblSubtotal.text = transactionInfo.subTotal.toPrice()
        lblFees.text = transactionInfo.gestionFee.toPrice()
        lblTotal.text = transactionInfo.amountPayment.toPrice()
        lblPromoCode.text = "-" + transactionInfo.amountPromoCodeUsed.toPrice()
        lblUsedWallet.text = "-" + transactionInfo.amountWalledUsed.toPrice()
        showPaymentMethod(transactionInfo)

        var y: CGFloat = 14
        if transactionInfo.amountPromoCodeUsed > 0 {
            lblPromoCode.isHidden = false
            lblPromoCodeTitle.isHidden = false
            y += 30
        } else {
            lblPromoCode.isHidden = true
            lblPromoCodeTitle.isHidden = true
        }

        lcUsedWalletTop.constant = y

        if transactionInfo.amountWalledUsed > 0 {
            lblUsedWallet.isHidden = false
            lblUsedWalletTitle.isHidden = false
            y += 30
        } else {
            lblUsedWallet.isHidden = true
            lblUsedWalletTitle.isHidden = true
        }

        lcFeesTop.constant = y

        showRefund(transactionInfo)
        showMap(transactionInfo)
        showInvoice(transactionInfo)

        view.layoutIfNeeded()
    }

    @IBAction func problem() {
        UIDevice.vibrate()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            guard let piReference = self.purchase.payment else {
                self.showError("Payment reference not found")
                return
            }

            let loading = BlurryLoadingView.showAndStart()
            API.shared.getSaleByPiReference(piReference: piReference) { (sale, error) in
                loading.stopAndHide()
                if let error = error {
                    self.show(error: error)
                    return
                }

                self.loadRemoteConfigAndRunSupport(sale: sale)
            }
        }
    }

    func loadRemoteConfigAndRunSupport(sale: Sale?) {
        let blurryLoading = BlurryLoadingView.showAndStart()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        appDelegate.remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        appDelegate.remoteConfig.configSettings = settings
        appDelegate.remoteConfig.fetchAndActivate { (_, _) -> Void in
            blurryLoading.stopAndHide()
            self.performSegue(withIdentifier: "Support", sender: sale)
        }
    }

    @IBAction func facturaPreview() {
        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if self.pdfData == nil || !self.hasValidPdf {
                self.showError("Aún estamos generando tu factura simplificada, vuélvelo a intentar en unos minutos",
                               delegate: {
                    // No action required
                }, title: "Ups!")
            } else {
                self.performSegue(withIdentifier: "SupportInvoice", sender: self)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let supportVC = segue.destination as? SupportViewController {
            supportVC.sale = sender as? Sale
        } else if let supportInvoiceVC = segue.destination as? SupportInvoiceViewController {
            supportInvoiceVC.pdfData = self.pdfData
            supportInvoiceVC.sale = Sale(dict: [:])
            supportInvoiceVC.sale?.piReference = self.purchase.payment
        }
    }

    @IBAction func showLocationInfo() {
        self.showInfo(title: "info.locationTitle".localized,
                      description: "info.locationDescription".localized)
    }

    @IBAction func showFacturaInfo() {
        self.showInfo(title: "info.facturaTitle".localized,
                      description: "info.facturaDescription".localized)
    }

    @IBAction func hideInfo() {
        UIView.animate(withDuration: 0.3) {
            self.vInfoBox.alpha = 0.0
        } completion: { (_) in
            self.vInfoBox.isHidden = true
        }
    }

    private func showInfo(title: String, description: String) {
        self.lblInfoTitle.text = title

        let style = NSMutableParagraphStyle()
        style.lineSpacing = 20
        self.lblInfoDescription.attributedText = NSAttributedString(
            string: description,
            attributes: [
                NSAttributedString.Key.font: AppFont.regular[13],
                NSAttributedString.Key.paragraphStyle: style
            ]
        )

        self.vInfoBox.alpha = 0.0
        self.vInfoBox.isHidden = false

        UIView.animate(withDuration: 0.3) {
            self.vInfoBox.alpha = 1.0
        }
    }
}
