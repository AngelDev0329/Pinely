import UIKit
import Photos

class GridView: UIView {

  // MARK: - Initialization

  lazy var topView: UIView = self.makeTopView()
  lazy var bottomView: UIView = self.makeBottomView()
  lazy var bottomBlurView: UIVisualEffectView = self.makeBottomBlurView()
  lazy var arrowButton: ArrowButton = self.makeArrowButton()
  lazy var collectionView: UICollectionView = self.makeCollectionView()
  lazy var closeButton: UIButton = self.makeCloseButton()
  lazy var doneButton: UIButton = self.makeDoneButton()
  lazy var emptyView: UIView = self.makeEmptyView()
  lazy var loadingIndicator: UIActivityIndicatorView = self.makeLoadingIndicator()

  // MARK: - Initialization

  override init(frame: CGRect) {
    super.init(frame: frame)

    setup()
    loadingIndicator.startAnimating()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Setup

  private func setup() {
    [collectionView, bottomView, topView, emptyView, loadingIndicator].forEach {
      addSubview($0)
    }

    [closeButton, arrowButton].forEach {
      topView.addSubview($0)
    }

    [bottomBlurView, doneButton].forEach {
      bottomView.addSubview($0 )
    }

    Constraint.on(
      topView.leftAnchor.constraint(equalTo: topView.superview!.leftAnchor),
      topView.rightAnchor.constraint(equalTo: topView.superview!.rightAnchor),
      topView.heightAnchor.constraint(equalToConstant: 40),

      loadingIndicator.centerXAnchor.constraint(equalTo: loadingIndicator.superview!.centerXAnchor),
      loadingIndicator.centerYAnchor.constraint(equalTo: loadingIndicator.superview!.centerYAnchor)
    )

    if #available(iOS 11, *) {
      Constraint.on(
        topView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor)
      )
    } else {
      Constraint.on(
        topView.topAnchor.constraint(equalTo: topView.superview!.topAnchor)
      )
    }

    bottomView.gPinDownward()
    bottomView.gPin(height: 80)

    emptyView.gPinEdges(view: collectionView)

    collectionView.gPinDownward()
    collectionView.gPin(on: .top, view: topView, on: .bottom, constant: 1)

    bottomBlurView.gPinEdges()

    closeButton.gPin(on: .top)
    closeButton.gPin(on: .left)
    closeButton.gPin(size: CGSize(width: 40, height: 40))

    arrowButton.gPinCenter()
    arrowButton.gPin(height: 40)

    doneButton.gPin(on: .centerY)
    doneButton.gPin(on: .right, constant: -38)
  }

  // MARK: - Controls

  private func makeTopView() -> UIView {
    let view = UIView()
    view.backgroundColor = UIColor.white

    return view
  }

  private func makeBottomView() -> UIView {
    let view = UIView()

    return view
  }

  private func makeBottomBlurView() -> UIVisualEffectView {
    let view = UIVisualEffectView(effect: UIBlurEffect(style: .dark))

    return view
  }

  private func makeArrowButton() -> ArrowButton {
    let button = ArrowButton()
    button.layoutSubviews()

    return button
  }

  private func makeCloseButton() -> UIButton {
    let button = UIButton(type: .custom)
    button.setImage(GalleryBundle.image("gallery_close")?.withRenderingMode(.alwaysTemplate), for: UIControl.State())
    button.tintColor = Config.Grid.CloseButton.tintColor

    return button
  }

  private func makeDoneButton() -> UIButton {
    let button = UIButton(type: .system)
    button.setTitleColor(UIColor.white, for: UIControl.State())
    button.setTitleColor(UIColor.lightGray, for: .disabled)
    button.titleLabel?.font = Config.Font.Text.regular.withSize(16)
    button.setTitle("Gallery.Done".gLocalize(fallback: "Subir"), for: UIControl.State())

    return button
  }

  private func makeCollectionView() -> UICollectionView {
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 2
    layout.minimumLineSpacing = 2

    let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
    view.backgroundColor = UIColor.white

    return view
  }

  private func makeEmptyView() -> EmptyView {
    let view = EmptyView()
    view.isHidden = true

    return view
  }

  private func makeLoadingIndicator() -> UIActivityIndicatorView {
    let view = UIActivityIndicatorView(style: .whiteLarge)
    view.color = .gray
    view.hidesWhenStopped = true

    return view
  }
}
