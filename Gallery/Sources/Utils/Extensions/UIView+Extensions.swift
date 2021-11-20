import UIKit

extension UIView {

  func gAddShadow() {
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.5
    layer.shadowOffset = CGSize(width: 0, height: 1)
    layer.shadowRadius = 1
  }

  func gAddRoundBorder() {
    layer.borderWidth = 1
    layer.borderColor = Config.Grid.FrameView.borderColor.cgColor
    layer.cornerRadius = 3
    clipsToBounds = true
  }

  func gQuickFade(visible: Bool = true) {
    UIView.animate(withDuration: 0.1, animations: {
      self.alpha = visible ? 1 : 0
    })
  }

  func gFade(visible: Bool) {
    UIView.animate(withDuration: 0.25, animations: {
      self.alpha = visible ? 1 : 0
    })
  }
}
