import Foundation

class EventHub {

  typealias Action = () -> Void

  static let shared = EventHub()

  // MARK: Initialization

  init() {
      // Initialization is not required
  }

  var close: Action?
  var doneWithImages: Action?
  var doneWithVideos: Action?
  var stackViewTouched: Action?
}
