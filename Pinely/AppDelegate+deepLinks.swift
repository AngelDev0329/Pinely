//
//  AppDelegate+deepLinks.swift
//  Pinely
//

import UIKit
import FirebaseDynamicLinks

extension AppDelegate {
    fileprivate func handleCreateStaffLink() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let rootNc = mainStoryboard.instantiateInitialViewController() as? UINavigationController,
           let rootTc = rootNc.viewControllers.first as? UITabBarController,
           let homeNc = rootTc.viewControllers?.first as? UINavigationController,
           let homeVc = homeNc.viewControllers.first as? HomeViewController {
            homeVc.preopenStaff = true
            self.window?.rootViewController = rootNc
            self.window?.makeKeyAndVisible()
        }
    }

    fileprivate func handleOpenStaffProfileLink() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let rootNc = mainStoryboard.instantiateInitialViewController() as? UINavigationController,
           let rootTc = rootNc.viewControllers.first as? UITabBarController,
           let homeNc = rootTc.viewControllers?.first as? UINavigationController,
           let homeVc = homeNc.viewControllers.first as? HomeViewController {
            homeVc.preopenStaffMenu = true
            self.window?.rootViewController = rootNc
            self.window?.makeKeyAndVisible()
        }
    }

    fileprivate func handleEventLink(_ url: String) {
        var eventString = url.components(separatedBy: "event=")[1]
        var eventId = ""
        while !eventString.isEmpty {
            guard let char = eventString.first else { continue }
            eventString.remove(at: eventString.startIndex)
            if char >= "0" && char <= "9" {
                eventId.append(char)
            } else {
                break
            }
        }
        if let iEventId = Int(eventId) {
            // Open event
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            if let rootNc = mainStoryboard.instantiateInitialViewController() as? UINavigationController,
               let rootTc = rootNc.viewControllers.first as? UITabBarController,
               let homeNc = rootTc.viewControllers?.first as? UINavigationController,
               let roomVc = mainStoryboard.instantiateViewController(withIdentifier: "Event") as? EventViewController {
                homeNc.pushViewController(roomVc, animated: false)
                roomVc.eventId = iEventId
                self.window?.rootViewController = rootNc
                self.window?.makeKeyAndVisible()
            }
        }
    }

    fileprivate func handleRoomLink(_ url: String) {
        var roomString = url.components(separatedBy: "room=")[1]
        var roomId = ""
        while !roomString.isEmpty {
            guard let char = roomString.first else { continue }
            roomString.remove(at: roomString.startIndex)
            if char >= "0" && char <= "9" {
                roomId.append(char)
            } else {
                break
            }
        }
        if let iRoomId = Int(roomId) {
            // Open room
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            if let rootNc = mainStoryboard.instantiateInitialViewController() as? UINavigationController,
               let rootTc = rootNc.viewControllers.first as? UITabBarController,
               let homeNc = rootTc.viewControllers?.first as? UINavigationController,
               let roomVc = mainStoryboard.instantiateViewController(withIdentifier: "Place") as? PlaceViewController {
                homeNc.pushViewController(roomVc, animated: false)
                roomVc.placeId = iRoomId
                self.window?.rootViewController = rootNc
                self.window?.makeKeyAndVisible()
            }
        }
    }

    func handle(dynamicLink: DynamicLink) {
        if !appLoaded {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.handle(dynamicLink: dynamicLink)
            }
            return
        }
        guard let url = dynamicLink.url?.absoluteString else {
            return
        }
        if url.contains("/create-staff") || url.contains("/error") {
            handleCreateStaffLink()
        } else if url.contains("/open-staff-profile") {
            handleOpenStaffProfileLink()
        } else if url.contains("event=") {
            handleEventLink(url)
        } else if url.contains("room=") {
            handleRoomLink(url)
        }
    }
}
