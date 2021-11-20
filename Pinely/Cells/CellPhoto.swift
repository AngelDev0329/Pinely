//
//  CellPhoto.swift
//  Pinely
//

import UIKit
import Kingfisher

protocol CellPhotoDelegate: AnyObject {
    func photoSelected(photo: PhotoFakeOrReal)
}

class CellPhoto: UICollectionViewCell {
    @IBOutlet weak var ivPhoto: UIImageView!
    @IBOutlet weak var vOrangeFrame: UIView!

    var photo: PhotoFakeOrReal?
    weak var delegate: CellPhotoDelegate?

    func prepare(photo: PhotoFakeOrReal, delegate: CellPhotoDelegate?) {
        self.photo = photo
        self.delegate = delegate

        vOrangeFrame.isHidden = !photo.hasOrangeFrame

        if let urlString = photo.URLThumb,
           let url = URL(string: urlString) {
            ivPhoto.kf.setImage(with: url)
        } else {
            ivPhoto.image = nil
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
            self?.updateAllShadows()
        }
    }

    @IBAction func photoSelected() {
        UIDevice.vibrate()

        guard let photo = self.photo else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.delegate?.photoSelected(photo: photo)
        }
    }
}
