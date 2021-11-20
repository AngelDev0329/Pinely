//
//  UIImage+fromPdf.swift
//  Pinely
//

import UIKit

extension UIImageView {
    @discardableResult
    func fromPdf(fileUrl: URL, page: Int, width: CGFloat, height: CGFloat, fallbackImage: UIImage? = nil) -> Bool {
        guard let pdfDocument = CGPDFDocument(fileUrl as CFURL),
              pdfDocument.numberOfPages >= page
        else {
            if let fallbackImage = fallbackImage {
                self.image = fallbackImage
            }
            return false
        }

        let size = CGSize(width: width, height: height)

        if let pdfImage = UIImage.pdfImageWith(
            fileUrl, pageNumber: page,
            constraints: size) {
            self.image = pdfImage
            return true
        } else if let fallbackImage = fallbackImage {
            self.image = fallbackImage
        }

        return false
    }
}
