//
//  StaffViewCertificateViewController.swift
//  Pinely
//

import UIKit
import WebKit

class StaffViewCertificateViewController: StaffViewInWebViewBaseViewController {
    var url: URL?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let pdfUrl = url {
            let request = URLRequest(url: pdfUrl)
            aiLoading.startAnimating()
            wvPDF.navigationDelegate = self
            wvPDF.load(request)
        } else {
            aiLoading.stopAnimating()
        }
    }
}
