import UIKit

protocol VideoBoxDelegate: AnyObject {
  func videoBoxDidTap(_ videoBox: VideoBox)
}

class VideoBox: UIView {

  lazy var imageView: UIImageView = self.makeImageView()
  lazy var cameraImageView: UIImageView = self.makeCameraImageView()

  weak var delegate: VideoBoxDelegate?

  // MARK: - Initialization

  override init(frame: CGRect) {
    super.init(frame: frame)

    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Action

  @objc func viewTapped(_ gr: UITapGestureRecognizer) {
    delegate?.videoBoxDidTap(self)
  }

  // MARK: - Setup

  func setup() {
    backgroundColor = UIColor.clear
    imageView.gAddRoundBorder()

    let gr = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
    addGestureRecognizer(gr)

    [imageView, cameraImageView].forEach {
      self.addSubview($0)
    }

    imageView.gPinEdges()
    cameraImageView.gPin(on: .left, constant: 5)
    cameraImageView.gPin(on: .bottom, constant: -5)
    cameraImageView.gPin(size: CGSize(width: 12, height: 6))
  }

  // MARK: - Controls

  func makeImageView() -> UIImageView {
    let newImageView = UIImageView()
    newImageView.clipsToBounds = true

    return newImageView
  }

  func makeCameraImageView() -> UIImageView {
    let newImageView = UIImageView()
    newImageView.image = GalleryBundle.image("gallery_video_cell_camera")

    return newImageView
  }
}
