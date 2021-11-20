//
//  ButtonWithClickEffectFast.swift
//  Pinely
//

import UIKit

class ButtonWithClickEffectBFast: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        addTarget(self, action: #selector(clickStartedBFast), for: .touchDown)
        addTarget(self, action: #selector(clickEndedBFast), for: .touchUpInside)
        addTarget(self, action: #selector(clickEndedBFast), for: .touchUpOutside)
    }

    static var ongoingBClicks: [Int: Date] = [:]

    @IBAction func clickStartedBFast() {
        let hash = self.hash
        ButtonWithClickEffectBFast.ongoingBClicks[hash] = Date()
        UIView.animate(withDuration: 0.05) {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { _ in
            ButtonWithClickEffectBFast.ongoingBClicks.removeValue(forKey: hash)
        }
    }

    @IBAction func clickEndedBFast() {
        let hash = self.hash
        if let date = ButtonWithClickEffectBFast.ongoingBClicks[hash] {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01 - Date().timeIntervalSince(date)) {
                ButtonWithClickEffectBFast.ongoingBClicks.removeValue(forKey: hash)
                self.clickEnded()
            }
        } else {
            UIView.animate(withDuration: 0.01) {
                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        }
    }
}
