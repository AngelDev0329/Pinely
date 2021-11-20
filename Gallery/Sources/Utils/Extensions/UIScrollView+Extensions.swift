import UIKit

extension UIScrollView {

  func gScrollToTop() {
    setContentOffset(CGPoint.zero, animated: false)
  }

  func gUpdateBottomInset(_ value: CGFloat) {
    var inset = contentInset
    inset.bottom = value

    contentInset = inset
    scrollIndicatorInsets = inset
  }
}
