//
//  LoadingViewController.swift
//  Pinely
//

import UIKit
import FirebaseRemoteConfig

class LoadingViewController: ViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            nextScreen()
            return
        }

        appDelegate.remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        appDelegate.remoteConfig.configSettings = settings
        appDelegate.remoteConfig.fetch { (status, error) -> Void in
            if status == .success {
                print("Config fetched!")
                appDelegate.remoteConfig.activate { (_, _) in
                    self.nextScreen()
                }
            } else {
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
                self.nextScreen()
            }
        }
    }

    private func nextScreen() {
        DispatchQueue.main.async {
            let storyboardName: String
            if UserDefaults.standard.bool(forKey: "welcomeShown") {
                storyboardName = "Main"
            } else {
                storyboardName = "Welcome"
            }

            let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
            if let initialVC = storyboard.instantiateInitialViewController(),
               let appDelegate = UIApplication.shared.delegate as? AppDelegate,
               let window = appDelegate.window {
                appDelegate.appLoaded = true
                window.rootViewController = initialVC
                window.makeKeyAndVisible()
            }
        }
    }

    override var prefersStatusBarHidden: Bool {
        true
    }

}
