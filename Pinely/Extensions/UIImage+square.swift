//
//  UIImage+square.swift
//  Pinely
//

import UIKit

extension UIImage {
    func square() -> UIImage? {
        let originalWidth  = size.width
        let originalHeight = size.height
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        var edge: CGFloat = 0.0

        if originalWidth > originalHeight {
            // landscape
            edge = originalHeight
            x = (originalWidth - edge) / 2.0
            y = 0.0

        } else if originalHeight > originalWidth {
            // portrait
            edge = originalWidth
            x = 0.0
            y = (originalHeight - originalWidth) / 2.0
        } else {
            // square
            edge = originalWidth
        }

        let cropSquare = CGRect(x: x, y: y, width: edge, height: edge)
        guard let imageRef = cgImage?.cropping(to: cropSquare) else { return nil }

        return UIImage(cgImage: imageRef, scale: scale, orientation: imageOrientation)
    }
}
