//
// UIImage+PDF.swift. Copyright © 2016 Nigel Timothy Barber (@mindbrix). All rights reserved.
//

import UIKit

extension UIImage {
    static func pdfImageWith(_ url: URL, pageNumber: Int, width: CGFloat) -> UIImage? {
        return pdfImageWith(url, pageNumber: pageNumber, constraints: CGSize(width: width, height: 0))
    }

    static func pdfImageWith(_ url: URL, pageNumber: Int, height: CGFloat) -> UIImage? {
        return pdfImageWith(url, pageNumber: pageNumber, constraints: CGSize(width: 0, height: height))
    }

    static func pdfImageWith(_ url: URL, pageNumber: Int) -> UIImage? {
        return pdfImageWith(url, pageNumber: pageNumber, constraints: CGSize(width: 0, height: 0))
    }

    static func pdfImageWith(_ url: URL, pageNumber: Int, constraints: CGSize) -> UIImage? {
        guard let pdfDocument = CGPDFDocument(url as CFURL) else {
            return nil
        }

        print("Number of pages in PDF: \(pdfDocument.numberOfPages)")
        guard let page = pdfDocument.page(at: pageNumber) else {
            return nil
        }

        let size = page.getBoxRect(.mediaBox).size.forConstraints(constraints)
        let cacheURL = url.pdfCacheURL(pageNumber, size: size)

        if let url = cacheURL,
           FileManager.default.fileExists(atPath: url.path),
           let image = UIImage(contentsOfFile: url.path) {
            return UIImage(cgImage: image.cgImage!, scale: UIScreen.main.scale, orientation: .up)
        }

        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        context.concatenate(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height))
        let rect = page.getBoxRect(.mediaBox)
        context.translateBy(x: -rect.origin.x, y: -rect.origin.y)
        context.scaleBy(x: size.width / rect.size.width, y: size.height / rect.size.height)
        context.drawPDFPage(page)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let image = image {
            if let url = cacheURL,
               let imageData = image.pngData() {
                try? imageData.write(to: url, options: [])
            }
            return UIImage(cgImage: image.cgImage!, scale: UIScreen.main.scale, orientation: .up)
        } else {
            return nil
        }
    }

    static func pdfImageSizeWith(_ url: URL, pageNumber: Int, width: CGFloat) -> CGSize {
        if let pdfDocument = CGPDFDocument(url as CFURL),
           let page = pdfDocument.page(at: pageNumber) {
            return page.getBoxRect(.mediaBox).size.forConstraints(CGSize(width: width, height: 0))
        }
        return CGSize.zero
    }
}

// swiftlint:disable identifier_name
extension CGSize {
    func forConstraints(_ constraints: CGSize) -> CGSize {
        if constraints.width == 0 && constraints.height == 0 {
            return self
        }
        let sx = constraints.width / width
        let sy = constraints.height / height
        let s = sx != 0 && sy != 0 ? min(sx, sy) : max(sx, sy)
        return CGSize(width: ceil(width * s), height: ceil(height * s))
    }
}

extension URL {
    func pdfCacheURL(_ pageNumber: Int, size: CGSize) -> URL? {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: self.path)

            if let fileSize = attributes[FileAttributeKey.size] as? NSNumber,
               let fileDate = attributes[FileAttributeKey.modificationDate] as? Date {
                let hashables = self.path + fileSize.stringValue +
                    String(fileDate.timeIntervalSince1970) + String(describing: size) + "_" +
                    String(describing: pageNumber)

                let cacheDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] + "/__PDF_CACHE__"
                do {
                    try FileManager.default.createDirectory(atPath: cacheDirectory, withIntermediateDirectories: true, attributes: nil)

                } catch {}

                return URL(fileURLWithPath: cacheDirectory + "/" + String(format: "%2X", hashables.hash) + ".png")
            }
        } catch {}

        return nil
    }
}
