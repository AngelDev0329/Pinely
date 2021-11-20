import UIKit

class ArrowButton: UIButton {

  lazy var label: UILabel = self.makeLabel()
  lazy var arrow: UIImageView = self.makeArrow()

  let padding: CGFloat = 10
  let arrowSize: CGFloat = 8

  // MARK: - Initialization

  init() {
    super.init(frame: CGRect.zero)

    addSubview(label)
    addSubview(arrow)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    label.center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)

    arrow.frame.size = CGSize(width: arrowSize, height: arrowSize)
    arrow.center = CGPoint(x: label.frame.maxX + padding, y: bounds.size.height / 2)
  }

  override var intrinsicContentSize: CGSize {
    let size = super.intrinsicContentSize
    label.sizeToFit()

    return CGSize(width: label.frame.size.width + arrowSize*2 + padding,
                  height: size.height)
  }

  // MARK: - Logic

  func updateText(_ text: String) {
    var textUC = text.uppercased()
    if textUC == "RECENTS" {
        textUC = "RECIENTES"
    }
    label.text = textUC
    arrow.alpha = text.isEmpty ? 0 : 1
    invalidateIntrinsicContentSize()
  }

  func toggle(_ expanding: Bool) {
    let transform = expanding
      ? CGAffineTransform(rotationAngle: CGFloat(Double.pi)) : CGAffineTransform.identity

    UIView.animate(withDuration: 0.25, animations: {
      self.arrow.transform = transform
    })
  }

  // MARK: - Controls

  private func makeLabel() -> UILabel {
    let newLabel = UILabel()
    newLabel.textColor = Config.Grid.ArrowButton.tintColor
    newLabel.font = Config.Font.Main.regular.withSize(16)
    newLabel.textAlignment = .center

    return newLabel
  }

  private func makeArrow() -> UIImageView {
    let newArrow = UIImageView()
    newArrow.image = GalleryBundle.image("gallery_title_arrow")?.withRenderingMode(.alwaysTemplate)
    newArrow.tintColor = Config.Grid.ArrowButton.tintColor
    newArrow.alpha = 0

    return newArrow
  }

  // MARK: - Touch

  override var isHighlighted: Bool {
    didSet {
      label.textColor = isHighlighted ? UIColor.lightGray : Config.Grid.ArrowButton.tintColor
      arrow.tintColor = isHighlighted ? UIColor.lightGray : Config.Grid.ArrowButton.tintColor
    }
  }
}
