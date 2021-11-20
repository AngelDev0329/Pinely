//
//  String+attributedHTMLString.swift
//  Pinely
//

import UIKit

extension String {
    var attributedHTMLString: NSAttributedString {
        if let data = NSString(string: self).data(using: String.Encoding.unicode.rawValue),
            let attributedString = try? NSMutableAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html],
                documentAttributes: nil) {

            attributedString.enumerateAttribute(.font,
                                                in: NSRange(location: 0, length: attributedString.length),
                                                options: []) { value, range, _ in
                guard let currentFont = value as? UIFont else {
                    return
                }

                let font: UIFont
                if currentFont.fontName.lowercased().contains("bold") {
                    font = AppFont.bold[currentFont.pointSize]
                } else {
                    font = AppFont.regular[currentFont.pointSize]
                }
                attributedString.addAttributes([.font: font], range: range)
            }

            return attributedString
        } else {
            return NSAttributedString(string: self)
        }
    }
}
