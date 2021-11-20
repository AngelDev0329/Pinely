//
//  Bundle+appVersion.swift
//  Pinely
//

import Foundation

extension Bundle {
    var appVersion: String? {
        self.infoDictionary?["CFBundleShortVersionString"] as? String
    }

    var appBuild: String? {
        self.infoDictionary?["CFBundleVersion"] as? String
    }

    static var mainAppVersion: String? {
        Bundle.main.appVersion
    }

    static var mainAppBuild: String? {
        Bundle.main.appBuild
    }
}
