import UIKit

class EmptyView: UIView {

  lazy var imageView: UIImageView = self.makeImageView()
  lazy var label: UILabel = self.makeLabel()

  // MARK: - Initialization

  override init(frame: CGRect) {
    super.init(frame: frame)

    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Setup

  private func setup() {
    [label, imageView].forEach {
      addSubview($0 )
    }

    label.gPinCenter()
    imageView.gPin(on: .centerX)
    imageView.gPin(on: .bottom, view: label, on: .top, constant: -12)
  }

  // MARK: - Controls

  private func makeLabel() -> UILabel {
    let newLabel = UILabel()
    newLabel.textColor = Config.EmptyView.textColor
    newLabel.font = Config.Font.Text.regular.withSize(14)
    newLabel.text = "Gallery.EmptyView.Text".gLocalize(fallback: "Nothing to show")

    return newLabel
  }

  private func makeImageView() -> UIImageView {
    let newImageView = UIImageView()
    newImageView.image = Config.EmptyView.image

    return newImageView
  }
}
