//
//  WelcomeViewController.swift
//  Pinely
//
//  Created by Alexander Nekrasov on 04.07.21.
//  Copyright © 2021 Francisco de Asis Jimenez Tirado. All rights reserved.
//

import UIKit

class WelcomeViewController: LiquidSwipeContainerController {
    lazy var welcomeStoryboard = UIStoryboard(name: "Welcome", bundle: nil)

    override func viewDidLoad() {
        btnNext.tintColor = .white
        self.datasource = self
        self.delegate = self

        UserDefaults.standard.set(true, forKey: "welcomeShown")
    }

    @IBAction func skip() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let initialVC = storyboard.instantiateInitialViewController(),
               let appDelegate = UIApplication.shared.delegate as? AppDelegate,
               let window = appDelegate.window {
                window.rootViewController = initialVC
                window.makeKeyAndVisible()
            }
        }
    }
}

extension WelcomeViewController: LiquidSwipeContainerDataSource {
    func numberOfControllersInLiquidSwipeContainer(_ liquidSwipeContainer: LiquidSwipeContainerController) -> Int {
        4
    }

    private func buildWelcome1(_ viewController: UIViewController) {
        guard let translation = AppDelegate.translation else {
            return
        }

        if let title1 = translation.getString("welcome_screen_title1"),
           let label = viewController.view.viewWithTag(2) as? UILabel {
            let fontTop = AppFont.bold[35]
            let fontBottom = AppFont.bold[50]
            var components = title1.components(separatedBy: " ")
            let bottomString = components.last ?? ""
            components.removeLast()
            let topString = components.joined(separator: " ")
            let topStringAttributed = NSAttributedString(
                string: topString + "\n",
                attributes: [
                    NSAttributedString.Key.font: fontTop
                ]
            )
            let bottomStringAttributed = NSAttributedString(
                string: bottomString,
                attributes: [
                    NSAttributedString.Key.font: fontBottom
                ]
            )
            let fullStringAttributed = NSMutableAttributedString()
            fullStringAttributed.append(topStringAttributed)
            fullStringAttributed.append(bottomStringAttributed)
            label.attributedText = fullStringAttributed
        }
        if let desc = translation.getString("welcome_screen_description1"),
           let label = viewController.view.viewWithTag(3) as? UILabel {
            label.text = desc
        }
    }

    private func buildWelcome2(_ viewController: UIViewController) {
        if let translation = AppDelegate.translation,
           let title2 = translation.getString("welcome_screen_title2"),
           let label = viewController.view.viewWithTag(2) as? UILabel {
            label.text = title2
        }
    }

    private func buildWelcome3(_ viewController: UIViewController) {
        if let translation = AppDelegate.translation,
           let title3 = translation.getString("welcome_screen_title3"),
           let label = viewController.view.viewWithTag(2) as? UILabel {
            label.text = title3
        }
    }

    private func buildWelcome4(_ viewController: UIViewController) {
        guard let translation = AppDelegate.translation else {
            return
        }

        if let title4 = translation.getString("welcome_screen_title4"),
           let label = viewController.view.viewWithTag(2) as? UILabel {
            label.text = title4
        }
        if let buttonTitle = translation.getString("welcome_screen_button1"),
           let button = viewController.view.viewWithTag(3) as? UIButton {
            button.setTitle(buttonTitle, for: .normal)
        }
    }

    func liquidSwipeContainer(_ liquidSwipeContainer: LiquidSwipeContainerController,
                              viewControllerAtIndex index: Int) -> UIViewController {
        let viewController: UIViewController
        switch index {
        case 0:
            viewController = welcomeStoryboard.instantiateViewController(withIdentifier: "Welcome1")
            buildWelcome1(viewController)

        case 1:
            viewController = welcomeStoryboard.instantiateViewController(withIdentifier: "Welcome2")
            buildWelcome2(viewController)

        case 2:
            viewController = welcomeStoryboard.instantiateViewController(withIdentifier: "Welcome3")
            buildWelcome3(viewController)

        case 3:
            viewController = welcomeStoryboard.instantiateViewController(withIdentifier: "Welcome4")
            buildWelcome4(viewController)

        default:
            viewController = UIViewController()
        }

        let btnSkip = viewController.view.viewWithTag(1) as? UIButton
        btnSkip?.addTarget(self, action: #selector(self.skip), for: .touchUpInside)
        if let translation = AppDelegate.translation,
           let skipTitle = translation.getString("welcome_screen_skip") {
            btnSkip?.setTitle(skipTitle, for: .normal)
        }

        return viewController
    }
}

extension WelcomeViewController: LiquidSwipeContainerDelegate {
    func liquidSwipeContainer(_ liquidSwipeContainer: LiquidSwipeContainerController,
                              willTransitionTo: UIViewController) {
        btnNext.isHidden = true
        btnGo.isHidden = true
    }

    func liquidSwipeContainer(_ liquidSwipeContainer: LiquidSwipeContainerController,
                              didFinishTransitionTo: UIViewController,
                              transitionCompleted: Bool) {
        if currentPageIndex == 3 {
            btnNext.isHidden = true
            btnGo.isHidden = false
        } else {
            if currentPageIndex == 1 {
                btnNext.setImage(#imageLiteral(resourceName: "welcome_next_black"), for: .normal)
            } else {
                btnNext.setImage(#imageLiteral(resourceName: "welcome_next_white"), for: .normal)
            }
            btnNext.isHidden = false
            btnGo.isHidden = true
        }
    }
}
