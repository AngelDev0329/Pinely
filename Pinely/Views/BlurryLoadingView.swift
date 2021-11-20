//
//  BlurryLoadingView.swift
//  FacturLuz
//

import UIKit
import ICDMaterialActivityIndicatorView

class BlurryLoadingView: UIView {
    @IBOutlet var contentView: UIView!

    @IBOutlet weak var vLoadingBlurView: UIVisualEffectView!
    @IBOutlet weak var aiLoadingView: ICDMaterialActivityIndicatorView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        let nibName = "BlurryLoadingView"
        Bundle.main.loadNibNamed(nibName, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        vLoadingBlurView.effect = UIBlurEffect(style: .light)
        aiLoadingView.color = UIColor(named: "MainForegroundColor")
        aiLoadingView.activityIndicatorViewStyle = ICDMaterialActivityIndicatorViewStyleMedium
        aiLoadingView.startAnimating()
    }

    func stopAndHide() {
        UIView.animate(withDuration: 0.1) {
            self.contentView.alpha = 0.0
        } completion: { [weak self] (_) in
            self?.removeFromSuperview()
        }
    }

    static func showAndStart() -> BlurryLoadingView {
        let blurryLoadingView = BlurryLoadingView(frame: UIScreen.main.bounds)
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.window?.addSubview(blurryLoadingView)
        return blurryLoadingView
    }
}
