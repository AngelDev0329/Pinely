//
//  PlaceViewController+AXPhotosViewControllerDelegate.swift
//  Pinely
//

import UIKit
import AXPhotoViewer
import FirebaseAuth

extension PlaceViewController: AXPhotosViewControllerDelegate {
    func photosViewController(_ photosViewController: AXPhotosViewController,
                              didNavigateTo photo: AXPhotoProtocol, at index: Int) {
        let photos = local?
            .photos
            .filter { !$0.hasOrangeFrame }
        ?? []
        self.photoToDelete = photos[index]
        if self.photoToDelete != nil,
           Auth.auth().currentUser != nil,
           photoToDelete?.UID == Auth.auth().currentUser?.uid {
            photosViewController.overlayView.leftBarButtonItems = [
                UIBarButtonItem(barButtonSystemItem: .trash,
                                target: self,
                                action: #selector(PlaceViewController.deletePhoto))
            ]
        } else {
            photosViewController.overlayView.leftBarButtonItems = []
        }
    }
}
