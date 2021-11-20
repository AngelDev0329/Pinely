//
//  CellBanner.swift
//  Pinely
//

import UIKit

class CellBanner: UICollectionViewCell {
    @IBOutlet weak var vContainer: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescr: UILabel!

    var banner: Banner?

    func prepare(banner: Banner) {
        self.banner = banner

        lblTitle.text = banner.title
        lblDescr.text = banner.message

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.updateAllShadows()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        updateAllShadows()
    }

    @IBAction func openLink() {
        guard let banner = self.banner,
              !banner.link.isEmpty,
              let url = URL(string: banner.link)
        else { return }

        if UIApplication.shared.canOpenURL(url) {
            UIDevice.vibrate()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}
