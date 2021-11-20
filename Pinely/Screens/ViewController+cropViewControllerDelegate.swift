//
//  ViewController+cropViewControllerDelegate.swift
//  Pinely
//

import UIKit
import CropViewController

extension ViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController,
                            didCropToImage image: UIImage,
                            withRect cropRect: CGRect,
                            angle: Int) {
        self.galleryNavigator?.dismiss(animated: true) {
            self.galleryNavigator = nil
            self.photoSelected(image: image)
        }
    }
}
