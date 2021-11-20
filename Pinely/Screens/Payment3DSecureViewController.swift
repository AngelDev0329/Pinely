//
//  Payment3DSecureViewController.swift
//  Pinely
//

import UIKit
import WebKit
import SwiftEventBus

class Payment3DSecureViewController: ViewController {
    @IBOutlet weak var wbWeb: WKWebView!

    var paymentIntent: PaymentIntent!

    override func viewDidLoad() {
        super.viewDidLoad()

        wbWeb.uiDelegate = self
        wbWeb.navigationDelegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let url = paymentIntent.redirectUrl {
            let request = URLRequest(url: url)
            wbWeb.load(request)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        SwiftEventBus.post("paymentEnded")
    }
}

extension Payment3DSecureViewController: WKUIDelegate, WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.request.url?.absoluteString.contains("3d_secure/complete") == true {
            self.goBack()
        }
        decisionHandler(.allow)
    }
}
