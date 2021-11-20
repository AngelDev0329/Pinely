//
//  PlaceViewController+SwipeView.swift
//  Pinely
//

import UIKit
import SwipeView

extension PlaceViewController: SwipeViewDelegate, SwipeViewDataSource {
    func numberOfItems(in swipeView: SwipeView!) -> Int {
        3
    }

    func swipeView(_ swipeView: SwipeView!, viewForItemAt index: Int, reusing view: UIView!) -> UIView! {
        let placeTabView = (view as? PlaceTabView) ?? PlaceTabView(frame: swipeView.bounds)
        placeTabView.backgroundColor = .clear
        placeTabView.prepare(tabIndex: index, viewController: self, place: place, local: local, events: events, loaded: loaded, delegate: self)
        return placeTabView
    }

    func swipeViewCurrentItemIndexDidChange(_ swipeView: SwipeView!) {
        switch swipeView.currentItemIndex {
        case 0: showEventsTab()
        case 1: showPhotosTab()
        case 2: showInfoTab()
        default: break
        }
    }
}
