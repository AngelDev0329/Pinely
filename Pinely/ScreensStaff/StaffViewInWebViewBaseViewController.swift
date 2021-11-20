//
//  StaffViewInWebViewBaseViewController.swift
//  Pinely
//

import UIKit
import WebKit

class StaffViewInWebViewBaseViewController: ViewController, WKNavigationDelegate {
    @IBOutlet weak var wvPDF: WKWebView!
    @IBOutlet weak var aiLoading: UIActivityIndicatorView!

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        aiLoading.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        aiLoading.stopAnimating()
        self.show(error: error)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        aiLoading.stopAnimating()
        self.show(error: error)
    }

    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge,
                 completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let cred = URLCredential(trust: challenge.protectionSpace.serverTrust!)
        completionHandler(.useCredential, cred)
    }
}
