//
//  UIViewController+showWeb.swift
//  Pinely
//

import UIKit

extension UIViewController {
    func showWeb(title: String, pageLink: PageLink) {
        guard let url = pageLink.getUrl() else {
            return
        }

        let webStoryboard = UIStoryboard(name: "Web", bundle: nil)
        if let webVC = webStoryboard.instantiateInitialViewController() as? WebViewController {
            webVC.pageTitle = title
            webVC.pageUrl = url
            webVC.modalPresentationStyle = .fullScreen
            present(webVC, animated: true, completion: nil)
        }
    }
}
