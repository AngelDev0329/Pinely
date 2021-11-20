//
//  PlaceTabView.swift
//  Pinely
//

import UIKit
import FirebaseAuth

protocol PlaceTabViewDelegate: CellNoEventsDelegate, CellEventDelegate, CellPhotoDelegate {
    func refresh(delegate: @escaping () -> Void)
}

class PlaceTabView: UIView {
    @IBOutlet var contentView: UIView!

    @IBOutlet weak var cvEvents: UICollectionView!

    private let refreshControl = UIRefreshControl()

    var tabIndex: Int = 0
    var place: Place?
    var local: Local?
    var events: [Event] = []
    var loaded = false
    weak var delegate: PlaceTabViewDelegate?
    weak var viewController: ViewController?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        let nibName = "PlaceTabView"
        Bundle.main.loadNibNamed(nibName, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        cvEvents.register(nibName: "CellNoEvents", reusableId: "NoEvents")
        cvEvents.register(nibName: "CellEvent", reusableId: "Event")
        cvEvents.register(nibName: "CellInfoMap", reusableId: "InfoMap")
        cvEvents.register(nibName: "CellInfoDescription", reusableId: "InfoDescription")
        cvEvents.register(nibName: "CellPhotoBack", reusableId: "PhotoBack")
        cvEvents.register(nibName: "CellPhotoAdd", reusableId: "PhotoAdd")
        cvEvents.register(nibName: "CellPhoto", reusableId: "Photo")

        cvEvents.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
    }

    func prepare(tabIndex: Int, viewController: ViewController?,
                 place: Place?, local: Local?,
                 events: [Event], loaded: Bool,
                 delegate: PlaceTabViewDelegate?) {
        self.tabIndex = tabIndex
        self.viewController = viewController
        self.place = place
        self.local = local
        self.events = events
        self.loaded = loaded
        self.delegate = delegate

        cvEvents.reloadData()
    }

    @objc private func refresh(_ sender: Any?) {
        AppSound.uiRefreshFeed.play()
        if let delegate = self.delegate {
            delegate.refresh {
                self.refreshControl.endRefreshing()
            }
        } else {
            self.refreshControl.endRefreshing()
        }
    }
}

extension PlaceTabView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch tabIndex {
        case 0:
            // Events
            if events.count == 0 {
                if loaded {
                    return 1
                } else {
                    return 0
                }
            } else {
                return events.count
            }

        case 1:
            // Photos
            if canUploadPhotos {
                return (local?.photos.count ?? 0) + 1
            } else {
                return (local?.photos.count ?? 0)
            }

        case 2:
            // Information
            if local?.ubication != nil {
                return 2
            } else {
                return 1
            }

        default:
            return 0
        }
    }

    var canUploadPhotos: Bool {
        false
        // Auth.auth().currentUser != nil
    }

    private func cellForEventsTab(_ collectionView: UICollectionView, _ indexPath: IndexPath) -> UICollectionViewCell {
        if events.count == 0 {
            // No events
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoEvents", for: indexPath)
            if let cellNoEvents = cell as? CellNoEvents,
               let place = place {
                cellNoEvents.prepare(place: place, local: local, delegate: delegate)
            }
            return cell
        } else {
            // Events
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Event", for: indexPath)
            if let cellEvent = cell as? CellEvent {
                cellEvent.prepare(event: events[indexPath.item], delegate: delegate)
            }
            return cell
        }
    }

    private func cellForPhotosTab(_ indexPath: IndexPath, _ collectionView: UICollectionView) -> UICollectionViewCell {
        // Photos
        if indexPath.item == 0, canUploadPhotos {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAdd", for: indexPath) as? CellAddPhoto
            cell?.prepare()
            return cell ?? UICollectionViewCell()
        } else {
            let photo = canUploadPhotos ? self.local!.photos[indexPath.item - 1] : self.local!.photos[indexPath.item]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Photo", for: indexPath) as? CellPhoto
            cell?.prepare(photo: photo, delegate: delegate)
            return cell ?? UICollectionViewCell()
        }
    }

    private func cellForInfoTab(_ indexPath: IndexPath, _ collectionView: UICollectionView) -> UICollectionViewCell {
        // Information
        if indexPath.item == 0 && local?.ubication != nil {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InfoMap", for: indexPath) as? CellInfoMap
            if let local = local {
                cell?.prepare(local: local, viewController: viewController)
            }
            return cell ?? UICollectionViewCell()
        } else if indexPath.item == 1 || (indexPath.item == 0 && local?.ubication == nil) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InfoDescription", for: indexPath) as? CellInfoDescription
            cell?.prepare(local: local)
            return cell ?? UICollectionViewCell()
        } else {
            return UICollectionViewCell()
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch tabIndex {
        case 0:
            return cellForEventsTab(collectionView, indexPath)

        case 1:
            return cellForPhotosTab(indexPath, collectionView)

        case 2:
            return cellForInfoTab(indexPath, collectionView)

        default:
            return UICollectionViewCell()
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch tabIndex {
        case 0:
            let cellWidth = UIScreen.main.bounds.width - 40
            if events.count == 0 {
                // No events
                return CGSize(width: cellWidth, height: 440)
            } else {
                // Events
                let picWidth = cellWidth - 16
                let picHeight = picWidth * 145 / 368
                let cellHeight = picHeight + 16
                return CGSize(width: cellWidth, height: cellHeight)
            }

        case 1:
            if UIDevice.current.userInterfaceIdiom == .phone {
                // 3 items on iPhone
                let dimension = (UIScreen.main.bounds.width - 20) / 3
                return CGSize(width: dimension, height: dimension)
            } else {
                // Must be iPad or Mac M1
                return CGSize(width: 175, height: 175)
            }

        case 2:
            // Information
            if indexPath.item == 0 && local?.ubication != nil {
                let cellWidth = UIScreen.main.bounds.width - 40
                let picWidth = cellWidth - 16
                let picHeight = picWidth * 145 / 368
                let cellHeight = picHeight + 16
                return CGSize(width: cellWidth, height: cellHeight)
            } else {
                let cellWidth = UIScreen.main.bounds.width - 40
                let picWidth = cellWidth - 16
                // return CGSize(width: picWidth, height: 300)
                return CGSize(width: picWidth, height: CellInfoDescription.getHeight(local: local))
            }

        default:
            return CGSize(width: 0, height: 0)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
    }
}
