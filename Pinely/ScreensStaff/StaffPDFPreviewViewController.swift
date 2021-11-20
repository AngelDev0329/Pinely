//
//  StaffPDFPreviewViewController.swift
//  Pinely
//

import UIKit
import WebKit

class StaffPDFPreviewViewController: ViewController {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var webView: WKWebView!

    var url: URL!

    override func viewDidLoad() {
        super.viewDidLoad()

        if url.absoluteString.starts(with: "http") {
            let request = URLRequest(url: url)
            webView.load(request)
        } else {
            webView.loadFileURL(url, allowingReadAccessTo: url)
        }
    }
}
