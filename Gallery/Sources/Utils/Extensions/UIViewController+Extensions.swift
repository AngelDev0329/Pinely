import UIKit

extension UIViewController {

  func gAddChildController(_ controller: UIViewController) {
    addChild(controller)
    view.addSubview(controller.view)
    controller.didMove(toParent: self)

    controller.view.gPinEdges()
  }

  func gRemoveFromParentController() {
    willMove(toParent: nil)
    view.removeFromSuperview()
    removeFromParent()
  }
}
