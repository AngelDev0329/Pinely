import UIKit
import Photos

class VideoCell: ImageCell {

  lazy var cameraImageView: UIImageView = self.makeCameraImageView()
  lazy var durationLabel: UILabel = self.makeDurationLabel()
  lazy var bottomOverlay: UIView = self.makeBottomOverlay()

  // MARK: - Config

  func configure(_ video: Video) {
    super.configure(video.asset)

    video.fetchDuration { duration in
      DispatchQueue.main.async {
        self.durationLabel.text = "\(Utils.format(duration))"
      }
    }
  }

  // MARK: - Setup

  override func setup() {
    super.setup()

    [bottomOverlay, cameraImageView, durationLabel].forEach {
      self.insertSubview($0, belowSubview: self.highlightOverlay)
    }

    bottomOverlay.gPinDownward()
    bottomOverlay.gPin(height: 16)

    cameraImageView.gPin(on: .left, constant: 4)
    cameraImageView.gPin(on: .centerY, view: durationLabel, on: .centerY)
    cameraImageView.gPin(size: CGSize(width: 12, height: 6))

    durationLabel.gPin(on: .right, constant: -4)
    durationLabel.gPin(on: .bottom, constant: -2)
  }

  // MARK: - Controls

  func makeCameraImageView() -> UIImageView {
    let imageView = UIImageView()
    imageView.image = GalleryBundle.image("gallery_video_cell_camera")
    imageView.contentMode = .scaleAspectFit

    return imageView
  }

  func makeDurationLabel() -> UILabel {
    let label = UILabel()
    label.font = Config.Font.Text.bold.withSize(9)
    label.textColor = UIColor.white
    label.textAlignment = .right

    return label
  }

  func makeBottomOverlay() -> UIView {
    let view = UIView()
    view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

    return view
  }
}
