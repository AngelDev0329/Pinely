//
//  StaffPlaceEditViewController+CellPhotoDelegate.swift
//  Pinely
//

import UIKit

extension StaffPlaceEditViewController: CellPhotoDelegate {
    @objc func deletePhoto() {
        dismiss(animated: true)
    }

    func photoSelected(photo: PhotoFakeOrReal) {

    }
}
