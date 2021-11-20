//
//  UIView+clickEffect.swift
//  Pinely
//

import UIKit

extension UIView {
    static var ongoingClicks: [Int: Date] = [:]

    @IBAction func clickStarted() {
        let hash = self.hash
        if self.bounds.width > 150 || self.bounds.height > 150 {
            UIView.ongoingClicks[hash] = Date()
            UIView.animate(withDuration: 0.1) {
                self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            } completion: { _ in
                UIView.ongoingClicks.removeValue(forKey: hash)
            }
        } else {
            UIView.ongoingClicks[hash] = Date()
            UIView.animate(withDuration: 0.1) {
                self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            } completion: { _ in
                UIView.ongoingClicks.removeValue(forKey: hash)
            }
        }
    }

    @IBAction func clickStartedFast() {
        clickStarted()
    }

    @IBAction func clickEnded() {
        let hash = self.hash
        if let date = UIView.ongoingClicks[hash] {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 - Date().timeIntervalSince(date)) {
                UIView.ongoingClicks.removeValue(forKey: hash)
                self.clickEnded()
            }
        } else {
            UIView.animate(withDuration: 0.1) {
                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        }
    }

    @IBAction func clickEndedFast() {
        let hash = self.hash
        if let date = UIView.ongoingClicks[hash] {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05 - Date().timeIntervalSince(date)) {
                UIView.ongoingClicks.removeValue(forKey: hash)
                self.clickEnded()
            }
        } else {
            UIView.animate(withDuration: 0.05) {
                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        }
    }

    @IBAction func clickEndedFast2() {
        let hash = self.hash
        if let date = UIView.ongoingClicks[hash] {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2 - Date().timeIntervalSince(date)) {
                UIView.ongoingClicks.removeValue(forKey: hash)
                self.clickEnded()
            }
        } else {
            UIView.animate(withDuration: 0.05) {
                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        }
    }

    func cancelClick() {
        let hash = self.hash
        if UIView.ongoingClicks[hash] != nil {
            UIView.ongoingClicks.removeValue(forKey: hash)
        }
        self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
    }

}
