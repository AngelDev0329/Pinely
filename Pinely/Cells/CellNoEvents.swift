//
//  CellNoEvents.swift
//  Pinely
//

import UIKit

protocol CellNoEventsDelegate: AnyObject {
    func contactDirectly(place: Place)
}

class CellNoEvents: UICollectionViewCell {
    @IBOutlet weak var lblContactDirectly: UILabel!
    @IBOutlet weak var lblHead: UILabel!
    @IBOutlet weak var lblPlaceNoPinely: UILabel!
    @IBOutlet weak var vButtonContainer: UIView!
    @IBOutlet weak var lblLimitation: UILabel!
    @IBOutlet weak var lcTop: NSLayoutConstraint!
    @IBOutlet weak var lcMiddle: NSLayoutConstraint!

    var place: Place?
    weak var delegate: CellNoEventsDelegate?

    fileprivate func prepareSelling(_ place: Place) {
        if let translation = AppDelegate.translation {
            lblHead.text = translation.getString("title_local_not_events_to_sell") ??
            "¡No hay eventos a la venta!"
            let fontStandard = AppFont.regular[13]
            let attributedText = NSAttributedString(
                string: translation.getString("description_local_not_events_to_sell") ??
                "Vuelve más tarde, por ahora \(place.name)\nno ha publicado ningún evento.",
                attributes: [.font: fontStandard]
            )
            lblPlaceNoPinely.attributedText = attributedText
        } else {
            lblHead.text = "¡No hay eventos a la venta!"
            let fontStandard = AppFont.regular[13]
            let attributedText = NSAttributedString(
                string: "Vuelve más tarde, por ahora \(place.name)\nno ha publicado ningún evento.",
                attributes: [.font: fontStandard]
            )
            lblPlaceNoPinely.attributedText = attributedText
        }

        lcTop.constant = 0
        lcMiddle.constant = 30
        vButtonContainer.isHidden = true
        lblLimitation.isHidden = true
    }

    fileprivate func prepareNotSelling(_ place: Place, _ local: Local?) {
        let translation = AppDelegate.translation
        lblHead.text = translation?.getString("title_local_not_sell_tickets") ??
            "¡Esta sala no vende entradas con Pinely!"

        if let buttonMessage = translation?.getString("button_local_not_sell_tickets") {
            lblContactDirectly.text = "\(buttonMessage) \(place.name)"
        } else {
            lblContactDirectly.text = "Enviar un mensaje directo a \(place.name)"
        }

        let fontStandard = AppFont.regular[13]
        let attributedText = NSMutableAttributedString()
        attributedText.append(NSAttributedString(
            string: translation?.getString("description_local_not_sell_tickets") ??
            "sendToInstagram".localized.replacingOccurrences(
                of: "$localName",
                with: local?.localName ?? place.name),
            attributes: [.font: fontStandard]))

        lblPlaceNoPinely.attributedText = attributedText

        lcTop.constant = 0
        lcMiddle.constant = -30
        vButtonContainer.isHidden = false
        lblLimitation.isHidden = false
    }

    func prepare(place: Place, local: Local?, delegate: CellNoEventsDelegate?) {
        self.place = place
        self.delegate = delegate

        if local?.areSelling == true {
            prepareSelling(place)
        } else {
            prepareNotSelling(place, local)
        }
        layoutIfNeeded()
    }

    @IBAction func contactDirectly() {
        guard let place = self.place else {
            return
        }

        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.delegate?.contactDirectly(place: place)
        }
    }
}
