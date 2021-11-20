# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'
use_frameworks!
inhibit_all_warnings!

target 'Pinely' do
  # Pods for Pinely
  pod 'Mixpanel-swift'
  pod 'Firebase/Analytics'
  pod 'Firebase/Performance'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/InAppMessaging'
  pod 'Firebase/DynamicLinks'
  pod 'Firebase/Auth'
  pod 'Firebase/Storage'
  pod 'Firebase/AppCheck'
  pod 'Stripe'
  pod 'SwipeableTabBarController'
  pod 'AFWebViewController', '~> 1.0'
  pod 'CardScan'
  pod 'EFQRCode', '~> 5.1.6'
  pod 'CropViewController'
  pod 'RSSelectionMenu'
  pod 'SwiftyGif'
  pod 'AXPhotoViewer'
  pod 'AXPhotoViewer/Kingfisher'
#  pod 'ViewAnimator'
  pod 'SignaturePad'
  pod 'libPhoneNumber-iOS', '~> 0.8'
  pod 'SwipeView'
  pod 'Instabug' 
  pod 'FacebookSDK'
  pod 'FacebookSDK/LoginKit'
  pod 'FacebookSDK/ShareKit'
  pod 'FacebookSDK/PlacesKit'
  pod 'FBSDKMessengerShareKit'
  pod 'ICDMaterialActivityIndicatorView'
  pod 'pop'

  pod 'GoogleSignIn'
  
  pod 'ReachabilitySwift'
  pod 'Alamofire'
  pod 'Kingfisher'
  
  pod 'GoogleMaps'
  pod 'GooglePlaces'
  
  pod 'PPBlinkID', '~> 5.7.1'
  
  pod 'SwiftEventBus', :tag => '5.0.1', :git => 'https://github.com/cesarferreira/SwiftEventBus.git'
  
  pod 'OneSignal', '>= 2.11.2', '< 3.0'

  target 'PinelyTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'PinelyUITests' do
    # Pods for testing
  end

end

target 'OneSignalNotificationServiceExtension' do
  pod 'OneSignal', '>= 2.11.2', '< 3.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['LD_NO_PIE'] = 'NO'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = "YES"
      config.build_settings['SWIFT_SUPPRESS_WARNINGS'] = "YES"
    end
  end
end
