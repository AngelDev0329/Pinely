import Foundation
import Photos
import AVFoundation

struct Permission {
  enum Status {
    case notDetermined
    case restricted
    case denied
    case authorized
    case limited
  }

  struct Photos {
    static var status: Status {
      switch PHPhotoLibrary.authorizationStatus() {
      case .notDetermined:
        return .notDetermined
      case .restricted:
        return .restricted
      case .denied:
        return .denied
      case .limited:
        return .limited
      case .authorized:
        return .authorized
      @unknown default:
        fatalError()
        }
    }

    static func request(_ completion: @escaping () -> Void) {
      PHPhotoLibrary.requestAuthorization { _ in
        completion()
      }
    }
  }

  struct Camera {
    static var needsPermission: Bool {
      return Config.tabsToShow.firstIndex(of: .cameraTab) != nil
    }

    static var status: Status {
      switch AVCaptureDevice.authorizationStatus(for: .video) {
      case .notDetermined:
        return .notDetermined
      case .restricted:
        return .restricted
      case .denied:
        return .denied
      case .authorized:
        return .authorized
      @unknown default:
        fatalError()
        }
    }

    static func request(_ completion: @escaping () -> Void) {
      AVCaptureDevice.requestAccess(for: .video) { _ in
        completion()
      }
    }
  }
}
