//
//  EventViewController.swift
//  Pinely
//

import UIKit
import FirebaseAuth
import FirebaseAnalytics
import SwiftEventBus

class EventViewController: ViewController {
    @IBOutlet weak var tvTickets: UITableView!
    @IBOutlet weak var lcTicketsHeight: NSLayoutConstraint!

    @IBOutlet weak var lcBottom: NSLayoutConstraint!

    @IBOutlet weak var ivCover: UIImageView!
    @IBOutlet weak var ivCoverGif: UIImageView!
    @IBOutlet weak var ivLogo: UIImageView!
    @IBOutlet weak var ivLogoGif: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!

    @IBOutlet weak var lblClothLabel: UILabel!
    @IBOutlet weak var lblMinAgeLabel: UILabel!
    @IBOutlet weak var lblSinceLabel: UILabel!
    @IBOutlet weak var lblEventToSell: UILabel!
    @IBOutlet weak var lblEventInfo: UILabel!

    @IBOutlet weak var lblClothes: UILabel!
    @IBOutlet weak var lblAge: UILabel!
    @IBOutlet weak var lblPrice: UILabel!

    @IBOutlet weak var lblInformation: UILabel!
    @IBOutlet weak var vExpandableShade: UIView!

    @IBOutlet weak var vLoadingCover: UIView!

    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnBackFront: UIButton!
    @IBOutlet weak var btnShareFront: UIButton!

    @IBOutlet weak var vBuyInformationalContainer: UIView!
    @IBOutlet weak var lblBuyTicketsInformational: UILabel!

    let notificationFeedbackGenerator = UINotificationFeedbackGenerator()

    var placeId: Int?
    var place: Place?
    var local: Local?

    var eventId: Int?
    var event: Event?

    var eventInfo: EventInfo?
    var eventRules: EventRules?

    var tickets: [Ticket] = []
    var loaded = false

    private var infoExpanded = false

    let gradientLayer = CAGradientLayer()

    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            let gifImage = try UIImage(gifName: "skeleton_effect.gif")
            ivCoverGif.setGifImage(gifImage)
        } catch {
            print(error)
        }

        do {
            let gifImage = try UIImage(gifName: "skeleton_effect_avatar.gif")
            ivLogoGif.setGifImage(gifImage)
        } catch {
            print(error)
        }

        preShowEvent()

        if let eventId = self.eventId,
           event == nil {
            // Opened from link, we need to load all information
            API.shared.getEventInformationExtended(eventId: eventId) { (local, event, eventInfo, eventRules, tickets, error) in
                if let error = error {
                    self.show(error: error) {
                        self.goBack()
                    }
                    return
                }
                self.place = local?.place
                self.local = local
                self.event = event
                self.eventInfo = eventInfo
                self.eventRules = eventRules
                self.loaded = true
                self.tickets = tickets
                self.showEvent()
            }
        } else {
            // loadLocal()
            getEventAndShow()
        }

        SwiftEventBus.post("cancelPreopens")

        if let translation = AppDelegate.translation {
            lblClothLabel.text = translation.getString("clothing_event_text") ?? lblClothLabel.text
            lblMinAgeLabel.text = translation.getString("age_event_text") ?? lblMinAgeLabel.text
            lblSinceLabel.text = translation.getString("minimun_price_event_text") ?? lblSinceLabel.text
            lblEventInfo.text = translation.getString("event_information") ?? lblEventInfo.text
            lblEventToSell.text = translation.getString("tickets_to_sale") ?? lblEventToSell.text
        }

        let mainBackgroundColor = UIColor(named: "MainBackgroundColor") ?? .white
        gradientLayer.colors = [
            mainBackgroundColor.withAlphaComponent(0.0).cgColor,
            mainBackgroundColor.withAlphaComponent(0.7).cgColor,
            mainBackgroundColor.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.frame = vExpandableShade.bounds
        vExpandableShade.layer.addSublayer(gradientLayer)
        vExpandableShade.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = vExpandableShade.bounds
    }

    private func getEventAndShow() {
        if let eventId = event?.id,
           eventInfo == nil || eventRules == nil {
            API.shared.getEventInformation(eventId: eventId) { (eventInfo, eventRules, tickets, error) in
                if let error = error {
                    self.show(error: error) {
                        self.goBack()
                    }
                    return
                }
                self.eventInfo = eventInfo
                self.eventRules = eventRules
                self.loaded = true
                self.tickets = tickets
                self.showEvent()
            }
        } else {
            self.showEvent()
        }
    }

    private func preShowEvent() {
        guard let event = self.event else {
            return
        }

        lblTitle.text = event.name

        if let date = event.startEvent {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy 'a las' HH:mm"
            lblSubtitle.text = dateFormatter.string(from: date)
        } else {
            lblSubtitle.text = ""
        }

        vLoadingCover.isHidden = false
    }

    private func showEvent() {
        loaded = true
        vLoadingCover.isHidden = true

        if !(local?.areSelling ?? place?.areSelling ?? true) {
            tickets = []
        }

        if let thumbUrl = eventInfo?.urlThumb ?? local?.thumb,
            let url = URL(string: thumbUrl) {
            ivCoverGif.stopAnimatingGif()
            ivCoverGif.image = nil
            ivCover.kf.setImage(with: url)
        }
        if let avatarUrl = eventInfo?.avatarLocal ?? local?.avatar,
            let url = URL(string: avatarUrl) {
            ivLogoGif.stopAnimatingGif()
            ivLogoGif.image = nil
            ivLogo.kf.setImage(with: url)
        }

        lblTitle.text = eventInfo?.nameEvent ?? event?.name ?? ""

        if let date = eventInfo?.startEvent ?? event?.startEvent {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy 'a las' HH:mm"
            lblSubtitle.text = dateFormatter.string(from: date)
        } else {
            lblSubtitle.text = ""
        }

        lblClothes.text = eventRules?.clothesRuleText ?? ""
        lblAge.text = AgeOptions.getTextViewFor(eventRules?.ageMin ?? 0)
        var priceMoreLow = eventRules?.priceMoreLow ?? 0
        if priceMoreLow < 0 {
            priceMoreLow = 0
        }

        let allPrices = tickets.compactMap { $0.priceTicket }.min()
        priceMoreLow = allPrices ?? priceMoreLow

        var dPriceMoreLow = Double(priceMoreLow) / 100.0
        if dPriceMoreLow < 0.0 {
            dPriceMoreLow = 0.0
        }

        lblPrice.text = dPriceMoreLow.toPrice()

//        lblInformation.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapLabel(gesture:))))

        showInformation()
        showTickets()
    }

    var expandingAvailable = false

    private func showInformation() {
        let htmlDescription = event?.description ?? ""
        let attrInfoString = NSMutableAttributedString(attributedString: htmlDescription.attributedHTMLString)
        attrInfoString.addAttributes([
            NSAttributedString.Key.foregroundColor: UIColor(named: "MainShadedColor")!
        ], range: NSRange(location: 0, length: attrInfoString.length))
        if attrInfoString.string.count < 180 {
            // Not show shadow effect on description event
            expandingAvailable = false
            lblInformation.attributedText = attrInfoString
            lblInformation.isUserInteractionEnabled = false
        } else {
            // Show shadow effect on description event
            expandingAvailable = true
            vExpandableShade.isHidden = infoExpanded
            if !infoExpanded {
                attrInfoString.mutableString.deleteCharacters(in: NSRange(location: 180, length: attrInfoString.mutableString.length - 180))
            }
            lblInformation.attributedText = attrInfoString
            lblInformation.isUserInteractionEnabled = true
        }
    }

    @IBAction func toggleDescriptionExpanded() {
        if !expandingAvailable {
            return
        }

        infoExpanded = !infoExpanded
        showInformation()
    }

    private func showTickets() {
        if eventInfo?.eventInformational ?? event?.eventInformational ?? false {
            // Show button
            tvTickets.isHidden = true
            vBuyInformationalContainer.isHidden = false
            let localName = local?.localName ?? ""
            if localName.isEmpty {
                lblBuyTicketsInformational.text = "Comprar entradas"
            } else {
                let buttonText = AppDelegate.translation?.getString("buy_external_text_button") ?? "Comprar entradas a"
                lblBuyTicketsInformational.text = "\(buttonText) \(localName)"
            }
            lcTicketsHeight.constant = CGFloat(80)
            lcBottom.constant = CGFloat(0)
        } else {
            // Show tickets
            tvTickets.isHidden = false
            vBuyInformationalContainer.isHidden = true
            tvTickets.reloadData()
            tvTickets.contentOffset = CGPoint()
            let ticketRows = max(tickets.count, 1)
            lcTicketsHeight.constant = CGFloat(ticketRows * 80)
            lcBottom.constant = max(CGFloat(0), CGFloat(80 - tickets.count * 80))
        }
        view.layoutIfNeeded()
    }

    @IBAction func share() {
        guard let eventId = event?.id else {
            return
        }

        let thumbUrl = event?.urlThumb ?? place?.thumbUrl ?? local?.thumb ?? ""
        let roomName = local?.localName ?? ""
        let eventName = event?.name ?? ""

        Analytics.logEvent("share_event", parameters: [
            "id_event": eventId,
            "name_event": eventName
        ])

        guard let link = ShareLink.event(eventId: eventId).url else {
            return
        }
        let imageUrl = URL(string: thumbUrl)

        generate(link: link,
                 title: "\(eventName) de \(roomName) en Pinely 🍍",
                 descriptionText: "Visita el perfil de \(roomName) para ver las entradas a la venta",
                 imageURL: imageUrl) { [weak self] (url) in
            guard let self = self else {
                return
            }

            let text = self.createShareText(
                stringId: "share.event.text", eventName: eventName,
                roomName: roomName, url: url)

            self.shareText(text, sourceView: self.btnShare)
        }
    }

    @IBAction func openBuyInformational() {
        UIDevice.vibrate()

        guard let urlButtonExternal = eventInfo?.urlButtonExternal ?? event?.urlButtonExternal,
              let url = URL(string: urlButtonExternal)
        else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    override var preferredStatusBarStyleInternal: UIStatusBarStyle {
        .lightContent
    }

    func showAmountSelector(ticket: Ticket) {
        _ = TicketAmountSelectorView.showAndStart(ticket: ticket, delegate: self)

        tabBarController?.tabBar.layer.zPosition = -1
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let checkoutVC = segue.destination as? CheckoutViewController {
            checkoutVC.place = self.place
            checkoutVC.local = self.local
            checkoutVC.event = self.event
            if let ticketAndCount = sender as? Ticket {
                checkoutVC.ticket = ticketAndCount
            }
        }
    }

    @IBAction func openLocal() {
        let mainStoryboard = self.storyboard ?? UIStoryboard(name: "Main", bundle: nil)
        if let placeVC = mainStoryboard.instantiateViewController(withIdentifier: "Place") as? PlaceViewController {
            placeVC.local = self.local
            placeVC.place = self.place
            placeVC.placeId = self.placeId
            navigationController?.pushViewController(placeVC, animated: true)
        }
    }
}

extension EventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if loaded {
            return max(1, tickets.count)
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row >= tickets.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoTickets", for: indexPath) as? CellNoTicket
            cell?.prepare()
            return cell ?? UITableViewCell()
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Ticket", for: indexPath) as? CellTicket
            cell?.prepare(ticket: tickets[indexPath.row], delegate: self)
            return cell ?? UITableViewCell()
        }
    }
}

extension EventViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        btnBackFront.isHidden = scrollView.contentOffset.y > 100
        btnShareFront.isHidden = scrollView.contentOffset.y > 100
    }
}

extension EventViewController: CellTicketDelegate {
    func buy(ticket: Ticket) {
        self.showAmountSelector(ticket: ticket)
    }

    func ticketAgotado(ticket: Ticket) {
        guard let translation = AppDelegate.translation else {
            return
        }

        let title = translation.getString("sold_out_tickets_popup_title")
        let descr = translation.getString("sold_out_tickets_popup_description")
        let button = translation.getString("sold_out_tickets_popup_button")

        let alert = UIAlertController(title: title, message: descr, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: button, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension EventViewController: TicketAmountSelectorViewDelegate {
    func ticketsSelected(ticket: Ticket, amount: Int) {
        if Auth.auth().currentUser == nil {
            let authSb = UIStoryboard(name: "Auth", bundle: nil)
            let authVc = authSb.instantiateInitialViewController()!
            self.present(authVc, animated: true)
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            if amount > 1 {
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                   let remoteConfig = appDelegate.remoteConfig,
                   remoteConfig.configValue(forKey: "single_ticket_recomendation").boolValue {
                    AppSound.logOut.play()
                    let translation = AppDelegate.translation ?? [:]
                    let alert = UIAlertController(title: translation.getStringOrKey("popup_title_howmanytickets"),
                                                  message: translation.getStringOrKey("popup_description_howmanytickets"),
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: translation.getStringOrKey("popup_button1_howmanytickets"),
                                                  style: .default) { _ in
                        // No action required
                    })
                    alert.addAction(UIAlertAction(title: translation.getStringOrKey("popup_button2_howmanytickets"),
                                                  style: .default) { [weak self] _ in
                        self?.checkoutTicketsConfirmed(ticket: ticket, amount: amount)
                    })
                    self?.present(alert, animated: true, completion: nil)
                } else {
                    self?.checkoutTicketsConfirmed(ticket: ticket, amount: amount)
                }
            } else {
                self?.checkoutTicketsConfirmed(ticket: ticket, amount: amount)
            }
        }
    }

    func checkoutTicketsConfirmed(ticket: Ticket, amount: Int) {
        var updatedTicket = ticket
        updatedTicket.amount = amount

        if let ticketIndex = self.tickets.firstIndex(where: { (ticket) -> Bool in ticket.id == updatedTicket.id }) {
            self.tickets[ticketIndex] = updatedTicket
        }

        if let eventId = updatedTicket.idEvent ?? self.event?.id {
            API.shared.saveShoppingCart(eventId: eventId)
        }

        notificationFeedbackGenerator.prepare()
        notificationFeedbackGenerator.notificationOccurred(.success)

        self.tvTickets.reloadData()

        self.performSegue(withIdentifier: "Checkout", sender: updatedTicket)
    }

    func ticketsSelectionDialogClosed() {
        self.tabBarController?.tabBar.layer.zPosition = 0
    }
}
