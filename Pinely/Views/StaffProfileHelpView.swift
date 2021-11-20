//
//  StaffProfileHelpView.swift
//  Pinely
//

import UIKit

class StaffProfileHelpView: UIView {
    @IBOutlet var contentView: UIView!

    @IBOutlet var btnNoShow: UIButton!

    var delegate: () -> Void = { } // swiftlint:disable:this weak_delegate

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        let nibName = "StaffProfileHelpView"
        Bundle.main.loadNibNamed(nibName, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height,
                                   width: UIScreen.main.bounds.width,
                                   height: UIScreen.main.bounds.height)
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.alpha = 0.0

        UIView.animate(withDuration: 0.3) {
            self.contentView.frame = UIScreen.main.bounds
            self.contentView.alpha = 1.0
        }
    }

    @IBAction func noShow() {
        btnNoShow.isSelected = !btnNoShow.isSelected
        UserDefaults.standard.setValue(btnNoShow.isSelected, forKey: "StaffHelpNoShow")
    }

    @IBAction func done() {
        UIView.animate(withDuration: 0.3) {
            self.contentView.alpha = 0.0
        } completion: { (_) in
            self.removeFromSuperview()
            self.delegate()
        }
    }

    static func showIfNecessary(delegate: @escaping () -> Void) {
        if UserDefaults.standard.bool(forKey: "StaffHelpNoShow") {
            delegate()
            return
        }

        let helpView = StaffProfileHelpView(frame: UIScreen.main.bounds)
        helpView.delegate = delegate
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.window?.addSubview(helpView)
    }
}
