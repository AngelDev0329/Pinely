//
//  StaffEventEditViewController.swift
//  Pinely
//

import UIKit
import FirebaseAuth

class StaffEventEditViewController: ViewController {
    @IBOutlet weak var tvTickets: UITableView!
    @IBOutlet weak var lcTicketsHeight: NSLayoutConstraint!

    @IBOutlet weak var lcBottom: NSLayoutConstraint!

    @IBOutlet weak var ivCover: UIImageView!
    @IBOutlet weak var ivCoverGif: UIImageView!
    @IBOutlet weak var ivLogo: UIImageView!
    @IBOutlet weak var ivLogoGif: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!

    @IBOutlet weak var lblClothes: UILabel!
    @IBOutlet weak var lblAge: UILabel!
    @IBOutlet weak var lblPrice: UILabel!

    @IBOutlet weak var lblInformation: UILabel!

    @IBOutlet weak var vLoadingCover: UIView!

    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnBackFront: UIButton!
    @IBOutlet weak var btnShareFront: UIButton!

    var placeId: Int?
    var place: Place?
    var local: Local?

    var event: Event!

    var eventInfo: EventInfo?
    var eventRules: EventRules?

    var tickets: [Ticket] = []

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

        if local == nil,
           let placeId = self.placeId ?? place?.id ?? event?.idLocal {
            API.shared.getLocal(id: placeId, place: place) { (local, error) in
                if let error = error {
                    self.show(error: error) {
                        self.goBack()
                    }
                    return
                }

                self.local = local
                if self.eventInfo != nil {
                    self.showEvent()
                } else {
                    self.getEventAndShow()
                }
            }
        } else {
            if eventInfo != nil {
                showEvent()
            } else {
                getEventAndShow()
            }
        }
    }

    private func getEventAndShow() {
        if let eventId = event.id {
            API.shared.getEventInformation(eventId: eventId) { (eventInfo, eventRules, tickets, error) in
                if let error = error {
                    self.show(error: error) {
                        self.goBack()
                    }
                    return
                }
                self.eventInfo = eventInfo
                self.eventRules = eventRules
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
        guard let local = self.local else {
            goBack()
            return
        }

        vLoadingCover.isHidden = true

        if !local.areSelling {
            tickets = []
        }

        if let thumbUrl = eventInfo?.urlThumb ?? local.thumb,
            let url = URL(string: thumbUrl) {
            ivCoverGif.stopAnimatingGif()
            ivCoverGif.image = nil
            ivCover.kf.setImage(with: url)
        }
        if let avatarUrl = eventInfo?.avatarLocal ?? local.avatar,
            let url = URL(string: avatarUrl) {
            ivLogoGif.stopAnimatingGif()
            ivLogoGif.image = nil
            ivLogo.kf.setImage(with: url)
        }

        lblTitle.text = eventInfo?.nameEvent ?? event.name

        if let date = eventInfo?.startEvent ?? event.startEvent {
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
        var dPriceMoreLow = Double(priceMoreLow) / 100.0
        if dPriceMoreLow < 0.0 {
            dPriceMoreLow = 0.0
        }
        lblPrice.text = dPriceMoreLow.toPrice()
        let htmlDescription = event.description ?? ""
        lblInformation.attributedText = htmlDescription.attributedHTMLString

        showTickets()
    }

    private func showTickets() {
        tvTickets.reloadData()
        tvTickets.contentOffset = CGPoint()
        lcTicketsHeight.constant = CGFloat((tickets.count + 1) * 80)
        lcBottom.constant = max(CGFloat(0), CGFloat(300 - (tickets.count + 1) * 80))
    }

    @IBAction func share() {
        guard let roomId = event.idLocal else {
            return
        }

        let roomName = local?.localName ?? ""

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

    @IBAction func editEventName(_ sender: Any) {
        self.performSegue(withIdentifier: "StaffEditEventInfo", sender: sender)
    }

    @IBAction func editDate(_ sender: Any) {
        self.performSegue(withIdentifier: "StaffEditEventInfo", sender: sender)
    }

    @IBAction func editClothes(_ sender: Any) {
        self.performSegue(withIdentifier: "StaffEditEventInfo", sender: sender)
    }

    @IBAction func editEventInfo(_ sender: Any) {
        self.performSegue(withIdentifier: "StaffEditEventInfo", sender: sender)
    }

    @IBAction func editMinAge(_ sender: Any) {
        self.performSegue(withIdentifier: "StaffEditEventInfo", sender: sender)
    }

    @IBAction func editMinPrice(_ sender: Any) {
        self.performSegue(withIdentifier: "StaffEditEventInfo", sender: sender)
    }

    override var preferredStatusBarStyleInternal: UIStatusBarStyle {
        .lightContent
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let staffEditEventInfoVC = segue.destination as? StaffEditEventInfoViewController {
            staffEditEventInfoVC.event = self.event
            staffEditEventInfoVC.eventRules = self.eventRules
            staffEditEventInfoVC.eventInfo = self.eventInfo
        }
    }
}

extension StaffEventEditViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1

        case 1:
            return tickets.count

        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddTicket", for: indexPath) as? CellAddTicket
            cell?.prepare(delegate: self)
            return cell ?? UITableViewCell()

        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditTicket", for: indexPath) as? CellEditTicket
            cell?.prepare(ticket: tickets[indexPath.row], delegate: self)
            return cell ?? UITableViewCell()

        default:
            return UITableViewCell()
        }

    }
}

extension StaffEventEditViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        btnBackFront.isHidden = scrollView.contentOffset.y > 100
        btnShareFront.isHidden = scrollView.contentOffset.y > 100
    }
}

extension StaffEventEditViewController: CellAddTicketDelegate {
    func addTicket() {

    }
}

extension StaffEventEditViewController: CellEditTicketDelegate {
    func edit(ticket: Ticket) {

    }
}
