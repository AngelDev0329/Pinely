//
//  CellEvent.swift
//  Pinely
//

import UIKit
import Kingfisher

protocol CellEventDelegate: AnyObject {
    func eventSelected(event: Event?)
}

class CellEvent: UICollectionViewCell {
    @IBOutlet weak var vContainer: UIView!
    @IBOutlet weak var ivBackground: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!

    var event: Event?
    weak var delegate: CellEventDelegate?

    func prepare(event: Event, delegate: CellEventDelegate?) {
        vContainer.transform = CGAffineTransform(scaleX: 1, y: 1)
        lblTitle.text = event.name
        lblSubTitle.text = event.subTitle
        if let urlString = event.urlThumb,
            !urlString.isEmpty,
            let url = URL(string: urlString) {
            ivBackground.kf.setImage(with: url)
        }

        self.event = event
        self.delegate = delegate
    }

    func prepare(event: Place, delegate: CellEventDelegate?) {
        vContainer.transform = CGAffineTransform(scaleX: 1, y: 1)
        lblTitle.text = event.name
        lblSubTitle.text = event.subTitle
        if let urlString = event.thumbUrl,
            !urlString.isEmpty,
            let url = URL(string: urlString) {
            ivBackground.kf.setImage(with: url)
        }

        self.event = nil
        self.delegate = delegate
    }

    @IBAction func placeSelected() {
        delegate?.eventSelected(event: event)
    }
}
