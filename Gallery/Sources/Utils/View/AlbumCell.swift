import UIKit

class AlbumCell: UITableViewCell {

  lazy var albumImageView: UIImageView = self.makeAlbumImageView()
  lazy var albumTitleLabel: UILabel = self.makeAlbumTitleLabel()
  lazy var itemCountLabel: UILabel = self.makeItemCountLabel()

  // MARK: - Initialization

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Config

  func configure(_ album: Album) {
    albumTitleLabel.text = album.collection.localizedTitle
    itemCountLabel.text = "\(album.items.count)"

    if let item = album.items.first {
      albumImageView.layoutIfNeeded()
      albumImageView.gLoadImage(item.asset)
    }
  }

  // MARK: - Setup

  func setup() {
    [albumImageView, albumTitleLabel, itemCountLabel].forEach {
      addSubview($0 )
    }

    albumImageView.gPin(on: .left, constant: 12)
    albumImageView.gPin(on: .top, constant: 5)
    albumImageView.gPin(on: .bottom, constant: -5)
    albumImageView.gPin(on: .width, view: albumImageView, on: .height)

    albumTitleLabel.gPin(on: .left, view: albumImageView, on: .right, constant: 10)
    albumTitleLabel.gPin(on: .top, constant: 24)
    albumTitleLabel.gPin(on: .right, constant: -10)

    itemCountLabel.gPin(on: .left, view: albumImageView, on: .right, constant: 10)
    itemCountLabel.gPin(on: .top, view: albumTitleLabel, on: .bottom, constant: 6)
  }

  // MARK: - Controls

  private func makeAlbumImageView() -> UIImageView {
    let imageView = UIImageView()
    imageView.clipsToBounds = true
    imageView.contentMode = .scaleAspectFill
    imageView.image = GalleryBundle.image("gallery_placeholder")

    return imageView
  }

  private func makeAlbumTitleLabel() -> UILabel {
    let label = UILabel()
    label.numberOfLines = 1
    label.font = Config.Font.Text.regular.withSize(14)

    return label
  }

  private func makeItemCountLabel() -> UILabel {
    let label = UILabel()
    label.numberOfLines = 1
    label.font = Config.Font.Text.regular.withSize(10)

    return label
  }
}
