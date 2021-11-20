//
//  MultiAcceptController.swift
//  Pinely
//

import UIKit

protocol MultiAcceptDelegate: AnyObject {
    func allAccepted()
}

class MultiAcceptController: UINavigationController {
    var titles: [String] = []
    var urls: [URL] = []
    weak var acceptDelegate: MultiAcceptDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        let authStoryboard = self.storyboard ?? UIStoryboard(name: "Auth", bundle: nil)
        guard let acceptVC = authStoryboard.instantiateViewController(withIdentifier: "Accept")
                as? AcceptViewController
        else {
            return
        }
        acceptVC.pageTitle = titles[0]
        acceptVC.pageUrl = urls[0]
        acceptVC.autoDismiss = false
        acceptVC.acceptDelegate = self
        viewControllers = [acceptVC]
    }
}

extension MultiAcceptController: AcceptDelegate {
    func accepted() {
        if self.viewControllers.count == self.titles.count {
            self.dismiss(animated: true) {
                self.acceptDelegate?.allAccepted()
            }
        } else {
            let authStoryboard = self.storyboard ?? UIStoryboard(name: "Auth", bundle: nil)
            guard let acceptVC = authStoryboard.instantiateViewController(withIdentifier: "Accept")
                as? AcceptViewController
            else {
                return
            }
            acceptVC.pageTitle = self.titles[self.viewControllers.count]
            acceptVC.pageUrl = self.urls[self.viewControllers.count]
            acceptVC.autoDismiss = false
            acceptVC.acceptDelegate = self
            self.pushViewController(acceptVC, animated: true)
        }
    }
}
