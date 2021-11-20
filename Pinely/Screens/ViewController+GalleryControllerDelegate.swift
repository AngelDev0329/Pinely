//
//  ViewController+GalleryControllerDelegate.swift
//  Pinely
//

import CropViewController
import Gallery
import UIKit

extension ViewController: GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [Gallery.Image]) {
        if images.count == 1 {
            images[0].resolve { (image) in
                guard let image = image else {
                    self.galleryNavigator?.dismiss(animated: true) {
                        self.galleryNavigator = nil
                        self.photoSelected(image: nil)
                    }
                    return
                }

                if let croppingStyle = self.croppingStyle {
                    let cropViewController = CropViewController(croppingStyle: croppingStyle, image: image)
                    cropViewController.doneButtonTitle = "button.upload".localized
                    cropViewController.cancelButtonTitle = "button.cancel".localized
                    cropViewController.delegate = self
                    self.galleryNavigator?.pushViewController(cropViewController, animated: true)
                } else {
                    self.galleryNavigator?.dismiss(animated: true) {
                        self.galleryNavigator = nil
                        self.photoSelected(image: image)
                    }
                }
            }
        } else {
            self.galleryNavigator?.dismiss(animated: true) {
                self.galleryNavigator = nil
                self.photoSelected(image: nil)
            }
        }
    }

    func galleryController(_ controller: GalleryController, requestLightbox images: [Gallery.Image]) {
        // No action required
    }

    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        // No action required
    }

    func galleryControllerDidCancel(_ controller: GalleryController) {
        self.galleryNavigator?.dismiss(animated: true) {
            self.galleryNavigator = nil
            self.photoSelected(image: nil)
        }
    }
}
