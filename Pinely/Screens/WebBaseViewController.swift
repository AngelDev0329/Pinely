//
//  WebBaseViewController.swift
//  Pinely
//

import Alamofire
import UIKit
import WebKit

class WebBaseViewController: ViewController, WKNavigationDelegate {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var wvWeb: WKWebView!

    var pageTitle: String!
    var pageUrl: URL!
    var autoDismiss = true
    var lastOffsetY: CGFloat = 0

    let session = Alamofire.Session()

    override func viewDidLoad() {
        super.viewDidLoad()

        lblTitle.text = pageTitle

        wvWeb.navigationDelegate = self
        wvWeb.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 48, right: 0)
        wvWeb.scrollView.showsHorizontalScrollIndicator = false
        wvWeb.scrollView.showsVerticalScrollIndicator = false
        wvWeb.scrollView.delegate = self
    }

    func loadPageFromWeb() {
        let loading = BlurryLoadingView.showAndStart()
        session.request(pageUrl).responseData { (response) in
            loading.stopAndHide()

            switch response.result {
            case .success(let htmlData):
                let html = WebViewController.createHtmlForWebView(htmlData: htmlData)
                let baseStr = self.pageUrl.scheme! + "://" + self.pageUrl.host!
                let baseURL = URL(string: baseStr)
                self.wvWeb.loadHTMLString(
                    html + "<p><br /></p><p><br /></p><p><br /></p><p><br /></p><p><br /></p><p><br /></p>",
                    baseURL: baseURL)

            case .failure(let error):
                self.show(error: error)
            }
        }
    }
}

extension WebBaseViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastOffsetY = scrollView.contentOffset.y
    }
}
