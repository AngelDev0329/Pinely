//
//  HomeViewController+Swipe.swift
//  Pinely
//

import UIKit
import SwipeView

extension HomeViewController: SwipeViewDelegate, SwipeViewDataSource {
    func numberOfItems(in swipeView: SwipeView!) -> Int {
        tabs.count
    }

    func swipeView(_ swipeView: SwipeView!, viewForItemAt index: Int, reusing view: UIView!) -> UIView! {
        let size = swipeViewItemSize(swipeView)
        let homeTabView = (view as? HomeTabView) ?? HomeTabView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        homeTabView.prepare(viewController: self, places: placesFiltered, events: eventsFiltered, tabIndex: index, delegate: self)
        return homeTabView
    }

    func swipeViewItemSize(_ swipeView: SwipeView!) -> CGSize {
        CGSize(
            width: UIScreen.main.bounds.width,
            height: swipeView.bounds.height
        )
    }

    func swipeViewCurrentItemIndexDidChange(_ swipeView: SwipeView!) {
        selectedTabIndex = swipeView.currentItemIndex
        cvTabs.reloadData()
    }
}
