//
//  ButtonWithClickEffect.swift
//  Pinely
//

import UIKit

class ButtonWithClickEffectFast: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        addTarget(self, action: #selector(clickStarted), for: .touchDown)
        addTarget(self, action: #selector(clickEndedFast2), for: .touchUpInside)
        addTarget(self, action: #selector(clickEndedFast2), for: .touchUpOutside)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if state == .highlighted {
            isHighlighted = false
        }
    }
}
