//
//  TabBarController.swift
//  Pinely
//

import UIKit
import SwiftEventBus
import FirebaseAuth
import Kingfisher

class TabBarController: UITabBarController {
    var currentTab = 0

    var tapRegognizer: UITapGestureRecognizer!
    var longPressRecognizer: UILongPressGestureRecognizer!
    var tapTicketsRegognizer: UITapGestureRecognizer!
    var tapNotificationsRegognizer: UITapGestureRecognizer!
    var vTickets: UIView!
    var vNotifications: UIView!
    var vHighlight: UIView!
    var imgView: UIImageView!

    var userRange = "client"

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self

        tapRegognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapRecognizerFired(_:)))
        tapTicketsRegognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapTicketsRecognizerFired(_:)))
        tapNotificationsRegognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapNotificationsRecognizerFired(_:)))

        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.recognizerFired(_:)))
        longPressRecognizer.minimumPressDuration = 0.5

        vTickets = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width / 4, height: tabBar.subviews[1].bounds.height))
        vTickets.isUserInteractionEnabled = true
        vTickets.backgroundColor = .clear
        vTickets.addGestureRecognizer(tapTicketsRegognizer)
        tabBar.subviews[1].addSubview(vTickets)

        vNotifications = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width / 4, height: tabBar.subviews[1].bounds.height))
        vNotifications.isUserInteractionEnabled = true
        vNotifications.backgroundColor = .clear
        vNotifications.addGestureRecognizer(tapNotificationsRegognizer)
        tabBar.subviews[2].addSubview(vNotifications)

        vHighlight = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        vHighlight.backgroundColor = .white
        vHighlight.isHidden = true
        vHighlight.cornerRadius = 18
        vHighlight.isUserInteractionEnabled = false
        tabBar.subviews[3].addSubview(vHighlight)

        imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 34, height: 34))
        imgView.contentMode = .scaleAspectFill
        imgView.layer.cornerRadius = 17
        imgView.layer.masksToBounds = true
        imgView.center = tabBar.subviews[3].center
        imgView.isUserInteractionEnabled = true
        tabBar.subviews[3].addSubview(imgView)

        imgView.addGestureRecognizer(tapRegognizer)
        imgView.addGestureRecognizer(longPressRecognizer)

        vHighlight.translatesAutoresizingMaskIntoConstraints = false
        imgView.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = imgView.centerXAnchor.constraint(equalTo: tabBar.subviews[3].centerXAnchor)
        let verticalConstraint = imgView.centerYAnchor.constraint(equalTo: tabBar.subviews[3].centerYAnchor)
        let widthConstraint = imgView.widthAnchor.constraint(equalToConstant: 34)
        let heightConstraint = imgView.heightAnchor.constraint(equalToConstant: 34)

        let horizontalConstraint2 = vHighlight.centerXAnchor.constraint(equalTo: tabBar.subviews[3].centerXAnchor)
        let verticalConstraint2 = vHighlight.centerYAnchor.constraint(equalTo: tabBar.subviews[3].centerYAnchor)
        let widthConstraint2 = vHighlight.widthAnchor.constraint(equalToConstant: 36)
        let heightConstraint2 = vHighlight.heightAnchor.constraint(equalToConstant: 36)

        tabBar.subviews[3].addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
        tabBar.subviews[3].addConstraints([horizontalConstraint2, verticalConstraint2, widthConstraint2, heightConstraint2])

        tabBar.layoutIfNeeded()
//        updateRange()

        SwiftEventBus.onMainThread(self, name: "authChanged") { (_) in
            self.setPicture()
//            self.updateRange()
        }

        SwiftEventBus.onMainThread(self, name: "profilePictureChanged") { (_) in
            self.setPicture()
        }
    }

    deinit {
        SwiftEventBus.unregister(self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setPicture()
    }

    func setPicture() {
        if let user = Auth.auth().currentUser,
            let photoURL = user.photoURL {
            imgView.kf.setImage(with: photoURL as Resource,
                            placeholder: #imageLiteral(resourceName: "TabCircle") as Placeholder,
                            options: [KingfisherOptionsInfoItem.scaleFactor(UIScreen.main.scale)] as KingfisherOptionsInfo,
                            progressBlock: nil as DownloadProgressBlock?,
                            completionHandler: { [weak self] (result) in
                                switch result {
                                case .success(_):
                                    break

                                case .failure(_):
                                    self?.imgView.image = #imageLiteral(resourceName: "AvatarPinely")
                                }
                            })
        } else {
            imgView.image = #imageLiteral(resourceName: "AvatarPinely")
        }
    }

    @objc func tapNotificationsRecognizerFired(_ recognizer: UITapGestureRecognizer) {
        if Auth.auth().currentUser == nil {
            let authSb = UIStoryboard(name: "Auth", bundle: nil)
            let authVc = authSb.instantiateInitialViewController()!
            present(authVc, animated: true, completion: nil)
        } else {
            selectedIndex = 2
        }
    }

    @objc func tapTicketsRecognizerFired(_ recognizer: UITapGestureRecognizer) {
        if Auth.auth().currentUser == nil {
            let authSb = UIStoryboard(name: "Auth", bundle: nil)
            let authVc = authSb.instantiateInitialViewController()!
            present(authVc, animated: true, completion: nil)
        } else {
            UIDevice.vibrate()
            let mainStoryboard = self.storyboard ?? UIStoryboard(name: "Main", bundle: nil)
            let myTicketsVC = mainStoryboard.instantiateViewController(withIdentifier: "MyTickets")
            present(myTicketsVC, animated: true)
        }
    }

    @objc func tapRecognizerFired(_ recognizer: UITapGestureRecognizer) {
        if Auth.auth().currentUser == nil {
            let authSb = UIStoryboard(name: "Auth", bundle: nil)
            let authVc = authSb.instantiateInitialViewController()!
            present(authVc, animated: true, completion: nil)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                let mainStoryboard = self.storyboard ?? UIStoryboard(name: "Main", bundle: nil)
                let profileVc = mainStoryboard.instantiateViewController(withIdentifier: "Profile")
                self.navigationController?.pushViewController(profileVc, animated: true)
            }
        }
    }

    @objc func recognizerFired(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state != .began {
            return
        }

        if Auth.auth().currentUser == nil {
            let authSb = UIStoryboard(name: "Auth", bundle: nil)
            let authVc = authSb.instantiateInitialViewController()!
            present(authVc, animated: true) { [weak self] in
                self?.selectedIndex = self?.currentTab ?? 0
            }
        } else {
            switch self.userRange {
            case "staff":
                // Staff
                let staffStoryboard = UIStoryboard(name: "Staff", bundle: nil)
                let initialVC = staffStoryboard.instantiateInitialViewController()!
                if let initialNC = initialVC as? UINavigationController {
                    let firstVC = initialNC.viewControllers[0]
                    self.navigationController?.pushViewController(firstVC, animated: true)
                } else {
                    self.navigationController?.pushViewController(initialVC, animated: true)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
                    self?.selectedIndex = self?.currentTab ?? 0
                }

            case "reader":
                // Reader
                let readerStoryboard = UIStoryboard(name: "Reader", bundle: nil)
                let initialVC = readerStoryboard.instantiateInitialViewController()!
                if let initialNC = initialVC as? UINavigationController {
                    let firstVC = initialNC.viewControllers[0]
                    self.navigationController?.pushViewController(firstVC, animated: true)
                } else {
                    self.navigationController?.pushViewController(initialVC, animated: true)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
                    self?.selectedIndex = self?.currentTab ?? 0
                }

            default:
                // Standard user
                let mainStoryboard = self.storyboard ?? UIStoryboard(name: "Main", bundle: nil)
                let myTicketsNc = mainStoryboard.instantiateViewController(withIdentifier: "MyTicketsNC")
                present(myTicketsNc, animated: true) { [weak self] in
                    self?.selectedIndex = self?.currentTab ?? 0
                }
            }
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }
}

extension TabBarController: UITabBarControllerDelegate {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag == 1 {
            if Auth.auth().currentUser == nil {
                let authSb = UIStoryboard(name: "Auth", bundle: nil)
                let authVc = authSb.instantiateInitialViewController()!
                self.present(authVc, animated: true)
            } else {
                UIDevice.vibrate()
                let mainStoryboard = self.storyboard ?? UIStoryboard(name: "Main", bundle: nil)
                let myTicketsVC = mainStoryboard.instantiateViewController(withIdentifier: "MyTickets")
                self.present(myTicketsVC, animated: true)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.selectedIndex = self.currentTab
            }
        } else if item.tag == 3 {
            if Auth.auth().currentUser == nil {
                let authSb = UIStoryboard(name: "Auth", bundle: nil)
                let authVc = authSb.instantiateInitialViewController()!
                present(authVc, animated: true) { [weak self] in
                    self?.selectedIndex = self?.currentTab ?? 0
                }
            } else {
                let mainStoryboard = self.storyboard ?? UIStoryboard(name: "Main", bundle: nil)
                let profileVc = mainStoryboard.instantiateViewController(withIdentifier: "Profile")
                self.navigationController?.pushViewController(profileVc, animated: true)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    self.selectedIndex = self.currentTab
                }
            }
        } else {
            currentTab = item.tag
        }
    }
}
