//
//  WebViewController.swift
//  Pinely
//

import UIKit
import WebKit

class WebViewController: WebBaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        if pageUrl.absoluteString.lowercased().hasSuffix("pdf") {
            let request = URLRequest(url: pageUrl)
            self.wvWeb.load(request)
        } else {
            self.loadPageFromWeb()
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // No action required
    }

    static func createHtmlForWebView(htmlData: Data) -> String {
        let style = """
@import url('https://fonts.googleapis.com/css2?family=Montserrat:wght@300;400;500;600;700;800&display=swap');

body {
    font-family: 'Montserrat';
    font-size: 14px;
}
h1, h2, h3, h4, h5, h6, p, .h1, .h2, .h3, .h4, .h5, .h6 {
    font-family: 'Montserrat';
}
"""

        var html = String(bytes: htmlData, encoding: .utf8)!
        if html.contains("<style>") && html.contains("</style>") {
            let htmlStart = html.components(separatedBy: "<style>")[0]
            let htmlEnd = html.components(separatedBy: "</style>")[1]
            html = "\(htmlStart)<style>\(style)</style>\(htmlEnd)"
        }
        html = html
            .replacingOccurrences(of: "<p", with: "<p style=\"font-family: Montserrat; font-weight: normal; font-size: 14;\"")
            .replacingOccurrences(of: "<h1", with: "<h1 style=\"font-family: Montserrat;\"")
            .replacingOccurrences(of: "<h2", with: "<h2 style=\"font-family: Montserrat;\"")
            .replacingOccurrences(of: "<h3", with: "<h3 style=\"font-family: Montserrat;\"")
            .replacingOccurrences(of: "<h4", with: "<h4 style=\"font-family: Montserrat;\"")
            .replacingOccurrences(of: "<h5", with: "<h5 style=\"font-family: Montserrat;\"")
            .replacingOccurrences(of: "<h6", with: "<h6 style=\"font-family: Montserrat;\"")
            .replacingOccurrences(of: "Poppins", with: "Montserrat")
        return html
    }
}
