//
//  StaffDNIPreviewViewController.swift
//  Pinely
//

import UIKit

class StaffDNIPreviewViewController: ViewController {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var ivPhoto: UIImageView!

    var photoTitle: String = ""
    var photoImage: UIImage?
    var photoUrl: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        lblTitle.text = photoTitle
        if let photoImage = self.photoImage {
            ivPhoto.image = photoImage
        } else if let photoUrl = self.photoUrl,
                  let url = URL(string: photoUrl) {
            ivPhoto.kf.setImage(with: url)
        }
    }
}

extension StaffDNIPreviewViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        ivPhoto
    }
}
