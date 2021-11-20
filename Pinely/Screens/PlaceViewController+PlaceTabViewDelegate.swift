//
//  PlaceViewController+PlaceTabViewDelegate.swift
//  Pinely
//

import UIKit

extension PlaceViewController: PlaceTabViewDelegate {
    func refresh(delegate: @escaping () -> Void) {
        guard let placeId = placeId ?? place?.id else {
            delegate()
            return
        }

        API.shared.getLocal(id: placeId, place: place) { (local, error) in
            if let error = error {
                self.show(error: error)
                return
            }

            self.local = local
            if self.local != nil {
                self.loadOrShow()
            }
            delegate()
        }
    }
}
