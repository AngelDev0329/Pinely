import Foundation

extension String {

  func gLocalize(fallback: String) -> String {
    let string = NSLocalizedString(self, comment: "")
    return string == self ? fallback : string
  }
}
