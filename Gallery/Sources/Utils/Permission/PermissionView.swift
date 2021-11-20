import UIKit

class PermissionView: UIView {

  lazy var imageView: UIImageView = self.makeImageView()
  lazy var label: UILabel = self.makeLabel()
  lazy var settingButton: UIButton = self.makeSettingButton()
  lazy var closeButton: UIButton = self.makeCloseButton()

  // MARK: - Initialization

  override init(frame: CGRect) {
    super.init(frame: frame)

    backgroundColor = UIColor.white
    setup()

  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Setup

  func setup() {
    [label, settingButton, closeButton, imageView].forEach {
      addSubview($0)
    }

    closeButton.gPin(on: .top)
    closeButton.gPin(on: .left)
    closeButton.gPin(size: CGSize(width: 44, height: 44))

    settingButton.gPinCenter()
    settingButton.gPin(height: 44)

    label.gPin(on: .bottom, view: settingButton, on: .top, constant: -24)
    label.gPinHorizontally(padding: 50)

    imageView.gPin(on: .centerX)
    imageView.gPin(on: .bottom, view: label, on: .top, constant: -16)
  }

  // MARK: - Controls

  func makeLabel() -> UILabel {
    let newLabel = UILabel()
    newLabel.textColor = Config.Permission.textColor
    newLabel.font = Config.Font.Text.regular.withSize(14)
    if Permission.Camera.needsPermission {
      newLabel.text = "GalleryAndCamera.Permission.Info".gLocalize(fallback: "Necesitamos que nos concedas permisos para que puedas subir fotos a tu perfil, haz click en Fotos y luego en 'Leer y escribir'")
    } else {
      newLabel.text = "Gallery.Permission.Info".gLocalize(fallback: "Necesitamos que nos concedas permisos para que puedas subir fotos a tu perfil, haz click en Fotos y luego en 'Leer y escribir'")
    }
    newLabel.textAlignment = .center
    newLabel.numberOfLines = 0
    newLabel.lineBreakMode = .byWordWrapping

    return newLabel
  }

  func makeSettingButton() -> UIButton {
    let button = UIButton(type: .custom)
    button.setTitle("Gallery.Permission.Button".gLocalize(fallback: "Dar permiso").uppercased(),
                    for: UIControl.State())
    button.backgroundColor = Config.Permission.Button.backgroundColor
    button.titleLabel?.font = Config.Font.Main.medium.withSize(16)
    button.setTitleColor(Config.Permission.Button.textColor, for: UIControl.State())
    button.setTitleColor(Config.Permission.Button.highlightedTextColor, for: .highlighted)
    button.layer.cornerRadius = 22
    button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

    return button
  }

  func makeCloseButton() -> UIButton {
    let button = UIButton(type: .custom)
    button.setImage(GalleryBundle.image("gallery_close")?.withRenderingMode(.alwaysTemplate), for: UIControl.State())
    button.tintColor = Config.Grid.CloseButton.tintColor

    return button
  }

  func makeImageView() -> UIImageView {
    let newImageView = UIImageView()
    newImageView.image = Config.Permission.image

    return newImageView
  }
}
