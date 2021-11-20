//
//  App-Check.swift
//  Pinely
//
//  Created by Francisco de Asis Jimenez Tirado on 25/7/21.
//  Copyright © 2021 Francisco de Asis Jimenez Tirado. All rights reserved.
//

import Foundation
import Firebase

class MyAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
  func createProvider(with firebaseApp: FirebaseApp) -> AppCheckProvider? {
    if #available(iOS 15.0, *) {
      return AppAttestProvider(app: firebaseApp)
    } else {
      return DeviceCheckProvider(app: firebaseApp)
    }
  }
}
