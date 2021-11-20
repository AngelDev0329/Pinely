//
//  AppDelegate.swift
//  Pinely
//
//  Created by Francisco de Asis Jimenez Tirado on 20/06/2020.
//  Copyright © 2020 Francisco de Asis Jimenez Tirado. All rights reserved.
//

import UIKit
import DeviceCheck
import FirebaseCore
import FirebaseAuth
import FirebaseAppCheck
import FirebaseDynamicLinks
import OneSignal
import SwiftEventBus
import Stripe
import GoogleMaps
import FirebaseCrashlytics
import Instabug
import FirebaseRemoteConfig
import Mixpanel

// swiftlint:disable identifier_name
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var remoteConfig: RemoteConfig!
    var appLoaded = false

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Replies.didRegisterForRemoteNotifications(withDeviceToken: deviceToken)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        _ = Replies.didReceiveRemoteNotification(userInfo)
    }

    private func initializeOneSignal(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        // Remove this method to stop OneSignal Debugging
        OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)

        // START OneSignal initialization code
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false, kOSSettingsKeyInAppLaunchURL: false]

        // Replace 'YOUR_ONESIGNAL_APP_ID' with your OneSignal App ID.
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "38240e3c-5115-495e-b930-4b8ed0c9eb23",
                                        handleNotificationAction: nil,
                                        settings: onesignalInitSettings)

        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification

        SwiftEventBus.onMainThread(self, name: "authChanged") { (_) in
            if Auth.auth().currentUser != nil {
                AppSound.confirmation.play()
                if !UserDefaults.standard.bool(forKey: "notificationsRequested") {
                    OneSignal.promptForPushNotifications(userResponse: { accepted in
                        UserDefaults.standard.set(true, forKey: "notificationsRequested")
                        print("User accepted notifications: \(accepted)")
                        if accepted {
                            API.shared.saveTokenDevice()
                        }
                    })
                } else {
                    API.shared.saveTokenDevice()
                }
            }
        }
    }

    private func initializeStyles() {
        let tabBarBackgroundColor = UIColor(named: "TabBarBackground") ?? .white
        let tabBarUnselectedColor = UIColor(named: "TabBarUnselected") ?? UIColor(hex: 0xDEDEDE)!
        UITabBar.appearance().layer.borderWidth = 0
        UITabBar.appearance().layer.borderColor = tabBarBackgroundColor.cgColor
        UITabBar.appearance().unselectedItemTintColor = tabBarUnselectedColor
        UITabBar.appearance().backgroundColor = tabBarBackgroundColor
        UITabBar.appearance().clipsToBounds = true
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        if #available(iOS 15.0, *) {
            let service = DCAppAttestService.shared
            if service.isSupported {
                let providerFactory = MyAppCheckProviderFactory()
                AppCheck.setAppCheckProviderFactory(providerFactory)
            }
        }
        FirebaseApp.configure()
        GMSServices.provideAPIKey("AIzaSyDiizqyGw657TxASTaTHymQsl2bOyfrjMM")

        DynamicLinks.performDiagnostics { (diagnosticOutput, hasErrors) in
            print(diagnosticOutput)
            print(hasErrors)
        }

        // START OneSignal initialization code
        initializeOneSignal(launchOptions)
        // END OneSignal initialization code

        // START MixPanel initialization code
        Mixpanel.initialize(token: "0b428098b8a412609c4cac444c6a723f")
        // END MixPanel initialization code

        // START InstaBug initialization code
        Instabug.start(withToken: "5cb3fe750ed2aa2b1abb56b0832aaa8e", invocationEvents: [.shake])
        if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject] {
            _ = Replies.didReceiveRemoteNotification(notification)
        }
        // END InstaBug initializataion code

        initializeStyles()

        // Stripe Integration PK key
        StripeAPI.defaultPublishableKey = "pk_live_uilrgmjyfAzow2mq0olTJwdM00qTd4xsRX"

        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)

        DispatchQueue.global().async {
            for sound in AppSound.allCases {
                sound.rawValue.prepareSound()
            }
        }

        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let url = userActivity.webpageURL {
                let stripeHandled = StripeAPI.handleURLCallback(with: url)
                if stripeHandled {
                    return true
                }
            }
        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, _) in
            if let dynamicLink = dynamiclink {
                self.handle(dynamicLink: dynamicLink)
            }
        }

        return handled
    }

    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        let stripeHandled = StripeAPI.handleURLCallback(with: url)
        if stripeHandled {
            return true
        } else if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            self.handle(dynamicLink: dynamicLink)
            return true
        }
        return false
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let stripeHandled = StripeAPI.handleURLCallback(with: url)
        if stripeHandled {
            return true
        } else if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            self.handle(dynamicLink: dynamicLink)
            return true
        }
        return false
    }

    var resignationTime: Date?

    func applicationDidBecomeActive(_ application: UIApplication) {
        SwiftEventBus.post("applicationDidBecomeActive")

        if let resignationTime = resignationTime,
           resignationTime.timeIntervalSince1970 + 5 * 60 < Date().timeIntervalSince1970 {
            // If more than 5 minutes passed, we restart the app
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            if let initialVC = mainStoryboard.instantiateInitialViewController() {
                window?.rootViewController = initialVC
                window?.makeKeyAndVisible()
            }
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        SwiftEventBus.post("applicationWillResignActive")
        resignationTime = Date()
    }

    func handleLinkTest() {
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

    static var translation: [String: Any]? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
           let remoteConfig = appDelegate.remoteConfig,
           let translation = remoteConfig.configValue(forKey: "translation").stringValue,
           let translationDict = translation.asDict {
            return translationDict
        } else {
            return nil
        }
    }
}
