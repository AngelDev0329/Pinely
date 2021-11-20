//
//  PlaceViewController+CellPhotoDelegate.swift
//  Pinely
//

import UIKit
import AXPhotoViewer

extension PlaceViewController: CellPhotoDelegate {
    @objc func deletePhoto() {
        dismiss(animated: true) {
            if let photo = self.photoToDelete {
                self.local?.photos.removeAll(where: { $0.URLFull == photo.URLFull })
                self.svPlaceTabs.reloadData()
            }
            if let photoReal = self.photoToDelete as? Photo {
                API.shared.deletePhotoLocal(
                    idLocal: self.placeId ?? self.place?.id ?? -1,
                    urlFull: photoReal.URLFull!) { (error) in
                        if let error = error {
                            self.show(error: error)
                        }
                    }
            } else if let photoFake = self.photoToDelete as? PhotoFakeLocal {
                var fakePhotos = PhotoFakeLocal.load()
                fakePhotos.removeAll(where: { $0.URLFull == photoFake.URLFull })
                PhotoFakeLocal.save(photos: fakePhotos)
            }
        }
    }

    func photoSelected(photo: PhotoFakeOrReal) {
        if photo.hasOrangeFrame {
            guard let urlString = photo.URLFull else {
                return
            }

            self.photoToDelete = photo
            let alert = UIAlertController(
                title: "alert.inRevision".localized,
                message: "alert.photoReview".localized,
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "button.continue".localized, style: .cancel) { _ in
                let photos = [
                    AXPhoto(attributedTitle: nil,
                            attributedDescription: nil,
                            attributedCredit: nil,
                            imageData: nil,
                            image: nil,
                            url: URL(string: urlString))
                ]
                let dataSource = AXPhotosDataSource(photos: photos, initialPhotoIndex: 0, prefetchBehavior: .regular)
                let photosVC = AXPhotosViewController(dataSource: dataSource)
                photosVC.overlayView.leftBarButtonItems = [
                    UIBarButtonItem(
                        barButtonSystemItem: .trash,
                        target: self,
                        action: #selector(PlaceViewController.deletePhoto))
                ]
                self.present(photosVC, animated: true)
            })
            present(alert, animated: true, completion: nil)
        } else {
            let photos = local?
                .photos
                .filter { !$0.hasOrangeFrame }
                .compactMap { URL(string: $0.URLFull ?? "") }
                .map { AXPhoto(attributedTitle: nil,
                               attributedDescription: nil,
                               attributedCredit: nil,
                               imageData: nil,
                               image: nil,
                               url: $0) }
            ?? []

            let initialPhotoIndex = photos.firstIndex(where: {
                $0.url?.absoluteString == photo.URLFull
            }) ?? 0

            let dataSource = AXPhotosDataSource(photos: photos, initialPhotoIndex: initialPhotoIndex, prefetchBehavior: .regular)
            let photosVC = AXPhotosViewController(dataSource: dataSource)
            photosVC.delegate = self
            photosVC.overlayView.leftBarButtonItems = []
            photosVC.overlayView.rightBarButtonItems = []
            present(photosVC, animated: true)

            self.photosViewController(photosVC, didNavigateTo: photos[initialPhotoIndex], at: initialPhotoIndex)
        }
    }
}
