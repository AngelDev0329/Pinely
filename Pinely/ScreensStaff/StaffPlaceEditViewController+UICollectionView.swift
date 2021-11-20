//
//  StaffPlaceEditViewController+UICollectionView.swift
//  Pinely
//

import UIKit

extension StaffPlaceEditViewController: UICollectionViewDelegate,
                                        UICollectionViewDataSource,
                                        UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView != cvEvents {
            return 0
        }

        switch selectedTabIndex {
        case 0:
            // Events
            return events.count + 1

        case 1:
            // Photos
            return (local?.photos.count ?? 0) + 1

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

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView != cvEvents {
            return UICollectionViewCell()
        }

        switch selectedTabIndex {
        case 0:
            if indexPath.item == 0 {
                // Add event
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddEvent", for: indexPath) as? CellAddEvent
                cell?.prepare(delegate: self)
                return cell ?? UICollectionViewCell()
            } else {
                // Events
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Event", for: indexPath) as? CellEvent
                cell?.prepare(event: events[indexPath.item - 1], delegate: self)
                return cell ?? UICollectionViewCell()
            }

        case 1:
            // Photos
            if indexPath.item == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAdd", for: indexPath)
                return cell
            } else {
                let photo = self.local!.photos[indexPath.item - 1]
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Photo", for: indexPath) as? CellPhoto
                cell?.prepare(photo: photo, delegate: self)
                return cell ?? UICollectionViewCell()
            }

        case 2:
            // Information
            if indexPath.item == 0 && local?.ubication != nil {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InfoMap", for: indexPath) as? CellInfoMap
                if let local = local {
                    cell?.prepare(local: local, viewController: self)
                }
                return cell ?? UICollectionViewCell()
            } else if indexPath.item == 1 || (indexPath.item == 0 && local?.ubication == nil) {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InfoDescription", for: indexPath) as? CellInfoDescription
                cell?.prepare(local: local)
                return cell ?? UICollectionViewCell()
            } else {
                return UICollectionViewCell()
            }

        default:
            return UICollectionViewCell()
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView != cvEvents {
            return CGSize(width: 0, height: 0)
        }

        switch selectedTabIndex {
        case 0:
            // Events
            let cellWidth = UIScreen.main.bounds.width - 40
            let picWidth = cellWidth - 16
            let picHeight = picWidth * 145 / 368
            let cellHeight = picHeight + 16
            return CGSize(width: cellWidth, height: cellHeight)

        case 1:
            // Photos
            if UIScreen.main.bounds.width <= 375 {
                return CGSize(width: 116, height: 116)
            } else {
                return CGSize(width: 126, height: 126)
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

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
    }
}
