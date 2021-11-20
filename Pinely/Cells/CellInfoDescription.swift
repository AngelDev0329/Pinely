//
//  CellInfoDescription.swift
//  Pinely
//

import UIKit

class CellInfoDescription: UICollectionViewCell {
    @IBOutlet weak var lblDescription: UILabel!

    func prepare(local: Local?) {
        let html = local?.information ?? ""
        let attributedString = NSMutableAttributedString(attributedString: html.attributedHTMLString)
        attributedString.addAttributes([
            NSAttributedString.Key.foregroundColor: UIColor(named: "MainForegroundColor")!
        ], range: NSRange(location: 0, length: attributedString.length))
        lblDescription.attributedText = attributedString
    }

    static func getHeight(local: Local?) -> CGFloat {
        let html = local?.information ?? ""
        let data = Data(html.utf8)
        if let attributedString = try? NSMutableAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil) {
            return attributedString.height(withConstrainedWidth: UIScreen.main.bounds.width - 48) + 32
        } else {
            return 32
        }
    }
}
