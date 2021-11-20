//
//  TicketQRViewController.swift
//  Pinely
//

import UIKit
import MapKit
import EFQRCode
import Kingfisher
import FirebaseRemoteConfig

class TicketQRViewController: ViewController {
    @IBOutlet weak var ivCover: UIImageView!
    @IBOutlet weak var ivLogo: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!

    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnBackFront: UIButton!
    @IBOutlet weak var btnShareFront: UIButton!

    @IBOutlet weak var lblInformation: UILabel!

    @IBOutlet weak var ivQR: UIImageView!

    @IBOutlet weak var svContainer: UIScrollView!

    @IBOutlet weak var lblDetails: UILabel!
    @IBOutlet weak var lblSupportButton: UILabel!
    @IBOutlet weak var lblQrInstructionDesc: UILabel!
    @IBOutlet weak var lblQrInstructionTitle: UILabel!
    @IBOutlet weak var mapView: MKMapView!

    var local: Local?
    var event: Event?
    var ticket: Ticket?
    var sale: Sale?
    var saleInfo: SaleInfo?
    var piReference: String?
    var requestRate = false

    var slideRecognizer = UISwipeGestureRecognizer()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let sale = sale,
            local == nil || event == nil || ticket == nil {
            loadData(sale: sale)
        }

        showData()

        slideRecognizer.addTarget(self, action: #selector(slidedBack))
        slideRecognizer.direction = .right
        svContainer.addGestureRecognizer(slideRecognizer)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if requestRate {
            requestRate = false
            AppStoreReviewManager.requestReviewIfAppropriate()
        }
    }

    func loadData(sale: Sale) {
        let loading = BlurryLoadingView.showAndStart()
        API.shared.getLET(sale: sale) { (local, event, ticket, error) in
            loading.stopAndHide()
            if let error = error {
                self.show(error: error)
                return
            }

            self.local = local
            self.event = event
            self.ticket = ticket
            self.showData(recreateSaleInfo: true)
        }
    }

    fileprivate func createSaleInfoIfNot(_ recreateSaleInfo: Bool) {
        if saleInfo == nil || recreateSaleInfo {
            saleInfo = SaleInfo()
            saleInfo?.localName = local?.localName
            saleInfo?.avatarUrl = local?.avatar
            saleInfo?.thumbUrl = local?.thumb
            saleInfo?.name = event?.name
            saleInfo?.QRCode = sale?.QRCode
            saleInfo?.number = sale?.number ?? 1
            saleInfo?.startEvent = event?.startEvent
            saleInfo?.finishEvent = event?.finishEvent
            saleInfo?.startValidation = ticket?.startValidation
            saleInfo?.finishValidation = ticket?.finishValidation
            saleInfo?.clothesRule = event?.clothesRule ?? 0
            saleInfo?.ageMin = event?.ageMin ?? 18
            saleInfo?.ubication = local?.ubication
        }
    }

    fileprivate func useTranslation(
        _ translation: [String: Any], _ entryCount: Int, _ dateFormat: DateFormatter,
        _ timeFormat: DateFormatter, _ clothes: String, _ ageMin: Int) {
        lblDetails.text =  translation.getString("ticket_title2")  ?? lblDetails.text
        lblSupportButton.text = translation.getString("ticket_button_text")  ?? lblSupportButton.text

        lblQrInstructionDesc.text = translation.getString("ticket_description1")  ?? lblQrInstructionDesc.text
        lblQrInstructionTitle.text = translation.getString("ticket_title1")  ?? lblQrInstructionTitle.text

        var strDesc: String? = translation.getString("ticket_description2")
        strDesc = strDesc?.replacingOccurrences(of: "$number", with: entryCount.toString())

        strDesc = strDesc?.replacingOccurrences(
            of: "$start_date_event",
            with: dateFormat.string(from: saleInfo?.startEvent ?? Date()) )
        strDesc = strDesc?.replacingOccurrences(
            of: "$start_hour_event",
            with: timeFormat.string(from: saleInfo?.startEvent ?? Date()).uppercased() )
        strDesc = strDesc?.replacingOccurrences(
            of: "$finish_date_event",
            with: dateFormat.string(from: saleInfo?.finishEvent ?? Date()) )
        strDesc = strDesc?.replacingOccurrences(
            of: "$finish_hour_event",
            with: timeFormat.string(from: saleInfo?.finishEvent ?? Date()).uppercased())
        strDesc = strDesc?.replacingOccurrences(of: "$clothing", with: clothes)
        strDesc = strDesc?.replacingOccurrences(of: "$age_min", with: ageMin.toString())

        if let attributedText = strDesc?.attributedHTMLString {
            let coloredAttributedText = NSMutableAttributedString(attributedString: attributedText)
            coloredAttributedText.addAttributes([
                .foregroundColor: UIColor.black
            ], range: NSRange(location: 0, length: coloredAttributedText.length))

            lblInformation.attributedText = coloredAttributedText
        }
    }

    fileprivate func useNoTranslation(
        _ styleStandard: [NSAttributedString.Key: Any], _ entryCount: Int,
        _ styleBold: [NSAttributedString.Key: Any], _ dateFormat: DateFormatter,
        _ timeFormat: DateFormatter, _ clothes: String, _ ageMin: Int) {
        let text = NSMutableAttributedString()
        text.append(NSAttributedString(string: "Tu código QR es válido por ", attributes: styleStandard))
        text.append(NSAttributedString(string: "\(entryCount)", attributes: styleBold))
        text.append(NSAttributedString(string: " entradas.\n", attributes: styleStandard))
        text.append(NSAttributedString(string: "El comienzo del evento es el ", attributes: styleStandard))
        text.append(NSAttributedString(string: dateFormat.string(from: saleInfo?.startEvent ?? Date()), attributes: styleBold))
        text.append(NSAttributedString(string: " a las ", attributes: styleStandard))
        text.append(NSAttributedString(string: timeFormat.string(from: saleInfo?.startEvent ?? Date()).uppercased(), attributes: styleBold))
        text.append(NSAttributedString(string: "y finaliza el ", attributes: styleStandard))
        text.append(NSAttributedString(string: dateFormat.string(from: saleInfo?.finishEvent ?? Date()), attributes: styleBold))
        text.append(NSAttributedString(string: " a las ", attributes: styleStandard))
        text.append(NSAttributedString(string: timeFormat.string(from: saleInfo?.finishEvent ?? Date()).uppercased(), attributes: styleBold))
        text.append(NSAttributedString(string: ".\n", attributes: styleStandard))
        text.append(NSAttributedString(string: "Recuerda de que tienes que validar tu entrada antes de las ", attributes: styleStandard))
        text.append(NSAttributedString(string: timeFormat.string(from: saleInfo?.finishValidation ?? Date()).uppercased(), attributes: styleBold))
        text.append(NSAttributedString(string: ".\n", attributes: styleStandard))
        text.append(NSAttributedString(
            string: "El código de vestimenta es \(clothes) y la edad mínima para poder acceder es de ",
            attributes: styleStandard))
        text.append(NSAttributedString(string: "\(ageMin) años", attributes: styleBold))
        text.append(NSAttributedString(string: ".\n", attributes: styleStandard))
        text.append(NSAttributedString(string: "Diviértete siempre con ", attributes: styleStandard))
        text.append(NSAttributedString(string: "responsabilidad", attributes: styleBold))
        text.append(NSAttributedString(string: ", si no sabes como llegar te ayudamos.", attributes: styleStandard))
        lblInformation.attributedText = text
    }

    func showData(recreateSaleInfo: Bool = false) {
        createSaleInfoIfNot(recreateSaleInfo)

        if let thumbUrl = local?.thumb ?? saleInfo?.thumbUrl,
            let url = URL(string: thumbUrl) {
            ivCover.kf.setImage(with: url)
        }
        if let avatarUrl = saleInfo?.avatarUrl,
            let url = URL(string: avatarUrl) {
            ivLogo.kf.setImage(with: url)
        }

        let qrCode = saleInfo?.QRCode ?? ""

        if let tryImage = EFQRCode.generate(content: qrCode) {
            ivQR.image = UIImage(cgImage: tryImage)
        }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4

        let styleStandard: [NSAttributedString.Key: Any] = [
            .font: AppFont.regular[13],
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor.black
        ]

        let styleBold: [NSAttributedString.Key: Any] = [
            .font: AppFont.semiBold[13],
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor.black
        ]

        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd/MM/yyyy"
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "h:mm a"

        let entryCount = saleInfo?.number ?? 0
        let ageMin = saleInfo?.ageMin ?? 18
        let clothes = "Formal"

        if let translation = AppDelegate.translation {
            useTranslation(translation, entryCount, dateFormat, timeFormat, clothes, ageMin)
        } else {
            useNoTranslation(styleStandard, entryCount, styleBold, dateFormat, timeFormat, clothes, ageMin)
        }

        if let location = saleInfo?.ubication {
            let diameter = 1000.0
            let region: MKCoordinateRegion = MKCoordinateRegion(
                center: location,
                latitudinalMeters: diameter,
                longitudinalMeters: diameter)
            self.mapView.setRegion(region, animated: false)

            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = saleInfo?.localName
            mapView.addAnnotation(annotation)
        }

        lblTitle.text = saleInfo?.name
    }

    @objc func slidedBack() {
        self.goBack()
    }

    @IBAction func share() {
        guard let roomId = sale?.localId,
              let link = ShareLink.room(roomId: roomId).url else {
            return
        }

        let roomName = local?.localName ?? ""

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

    @IBAction func placeSelected() {
        guard let saleInfo = self.saleInfo,
              let latitude = saleInfo.ubication?.latitude,
              let longitude = saleInfo.ubication?.longitude
        else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.openMapButtonAction(latitude: latitude, longitude: longitude)
        }
    }

    @IBAction func haveAProblem() {
        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if self.sale == nil,
               let piReference = self.piReference {
                // Load sale
                let loading = BlurryLoadingView.showAndStart()
                API.shared.getSaleByPiReference(piReference: piReference) { (sale, error) in
                    loading.stopAndHide()
                    if let error = error {
                        self.show(error: error)
                        return
                    }

                    self.sale = sale

                    self.runSupport()
                }
            } else if self.sale != nil {
                self.runSupport()
            } else {
                self.showError("error.piRefNotAvailable".localized)
            }
        }
    }

    private func runSupport() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let blurryLoading = BlurryLoadingView.showAndStart()
        appDelegate.remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        appDelegate.remoteConfig.configSettings = settings
        appDelegate.remoteConfig.fetchAndActivate { (_, _) -> Void in
            blurryLoading.stopAndHide()
            self.performSegue(withIdentifier: "Support", sender: self)
        }
    }

    override var preferredStatusBarStyleInternal: UIStatusBarStyle {
        .lightContent
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let supportVC = segue.destination as? SupportViewController {
            supportVC.sale = sale
        }
    }
}

extension TicketQRViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        btnBackFront.isHidden = scrollView.contentOffset.y > 100
        btnShareFront.isHidden = scrollView.contentOffset.y > 100
    }
}
