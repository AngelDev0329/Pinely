//
//  CellPlace.swift
//  Pinely
//

import UIKit
import Kingfisher

protocol CellPlaceDelegate: AnyObject {
    func placeSelected(place: Place)
}

class CellPlace: UICollectionViewCell {
    @IBOutlet weak var vContainer: UIView!
    @IBOutlet weak var ivBackground: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!

    var place: Place?
    weak var delegate: CellPlaceDelegate?

    func prepare(place: Place, delegate: CellPlaceDelegate?) {
        vContainer.transform = CGAffineTransform(scaleX: 1, y: 1)
        lblTitle.text = place.name
        lblSubTitle.text = place.subTitle
        if let urlString = place.thumbUrl,
            !urlString.isEmpty,
            let url = URL(string: urlString) {
            ivBackground.kf.setImage(with: url)
        }

        self.place = place
        self.delegate = delegate
    }

    @IBAction func placeSelected() {
        if let place = place {
            delegate?.placeSelected(place: place)
        }
    }
}
