//
//  AcceptViewController.swift
//  Pinely
//

import UIKit
import WebKit

protocol AcceptDelegate: AnyObject {
    func accepted()
}

class AcceptViewController: WebBaseViewController {
    @IBOutlet weak var vAcceptContainer: UIView!
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var btnBack: UIButton!

    weak var acceptDelegate: AcceptDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let navigationController = self.navigationController,
           navigationController.viewControllers.count >= 2 {
            // Can go back
            btnBack.setImage(#imageLiteral(resourceName: "BtnBack").withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            // Can only close
            btnBack.setImage(#imageLiteral(resourceName: "BtnClose").withRenderingMode(.alwaysTemplate), for: .normal)
        }

        loadPageFromWeb()

        vAcceptContainer.isHidden = true
    }

    @IBAction func accept() {
        UIDevice.vibrate()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if self.autoDismiss {
                self.dismiss(animated: true) {
                    self.acceptDelegate?.accepted()
                }
            } else {
                self.acceptDelegate?.accepted()
            }
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        vAcceptContainer.isHidden = false
    }
}
