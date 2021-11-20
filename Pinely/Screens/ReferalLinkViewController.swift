//
//  ReferalLinkViewController.swift
//  Pinely
//

import UIKit

class ReferalLinkViewController: ViewController {
    @IBOutlet weak var lblLink: UILabel!
    @IBOutlet weak var lblPremios: UILabel!

    @IBOutlet weak var vInfoPanel: UIView!
    @IBOutlet weak var vInfoPendientes: UIView!
    @IBOutlet weak var vInfoConseguidos: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        API.shared.checkReferredUrl { [weak self] url, error in
            if let error = error {
                self?.show(error: error, delegate: { [weak self] in
                    self?.goBack()
                }, title: "Ups!")
                return
            }

            if let url = url {
                self?.lblLink.text = url
            }
        }
    }

    @IBAction func copyLink() {
        UIDevice.vibrate()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            if let link = self?.lblLink.text {
                UIPasteboard.general.string = link
            }
        }
    }

    @IBAction func pendientesInfo() {
        vInfoPendientes.isHidden = false
        vInfoConseguidos.isHidden = true
        appearPanel()
    }

    @IBAction func conseguidosInfo() {
        vInfoPendientes.isHidden = true
        vInfoConseguidos.isHidden = false
        appearPanel()
    }

    private func appearPanel() {
        vInfoPanel.alpha = 0.0
        vInfoPanel.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.vInfoPanel.alpha = 1.0
        }
    }

    @IBAction func hidePanel() {
        UIView.animate(withDuration: 0.3) {
            self.vInfoPanel.alpha = 0.0
        } completion: { (_) in
            self.vInfoPanel.isHidden = true
        }
    }
}
