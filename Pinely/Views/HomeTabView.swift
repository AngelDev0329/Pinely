//
//  HomeTabView.swift
//  Pinely
//

import UIKit

protocol HomeTabViewDelegate: AnyObject {
    func layoutTabs()
    func refreshData(delegate: @escaping () -> Void)
    func contribute()
}

class HomeTabView: UIView {
    @IBOutlet var contentView: UIView!

    @IBOutlet weak var cvPlaces: UICollectionView!

    @IBOutlet weak var vNothingClose: UIView!
    @IBOutlet weak var lblNoHay: UILabel!
    @IBOutlet weak var lblNoHayMessage: UILabel!
    @IBOutlet weak var lblContribute: UILabel!

    var tabIndex: Int = 0
    weak var viewController: HomeViewController?
    weak var delegate: HomeTabViewDelegate?
    var placesFiltered: [Place] = []
    var eventsFiltered: [Event] = []

    private let refreshControl = UIRefreshControl()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        let nibName = "HomeTabView"
        Bundle.main.loadNibNamed(nibName, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        cvPlaces.showsVerticalScrollIndicator = false
        cvPlaces.showsHorizontalScrollIndicator = false
        cvPlaces.register(UINib(nibName: "CellBanner", bundle: nil), forCellWithReuseIdentifier: "Banner")
        cvPlaces.register(UINib(nibName: "CellEvent", bundle: nil), forCellWithReuseIdentifier: "Event")
        cvPlaces.register(UINib(nibName: "CellPlace", bundle: nil), forCellWithReuseIdentifier: "Place")

        cvPlaces.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshPlaces(_:)), for: .valueChanged)
    }

    func prepare(viewController: HomeViewController, places: [Place], events: [Event],
                 tabIndex: Int, delegate: HomeTabViewDelegate) {
        self.tabIndex = tabIndex
        self.delegate = delegate
        self.viewController = viewController

        if let translation = AppDelegate.translation {

            switch tabIndex {
            case 0:
                // Featured
                eventsFiltered = events
                lblNoHay.text = translation.getString("not_result_title_1") ?? "no_popular_near".localized
                lblNoHayMessage.text = translation.getString("not_result_description_1") ?? lblNoHayMessage.text
            case 1:
                // Discotecas
                placesFiltered = places
                    .filter { $0.type.lowercased() == "discoteca" }
                lblNoHay.text = translation.getString("not_result_title_2") ?? "no_disco_near".localized
                lblNoHayMessage.text = translation.getString("not_result_description_2") ?? lblNoHayMessage.text

            case 2:
                // Eventos
                placesFiltered = places
                    .filter { $0.type.lowercased() == "event" || $0.type.lowercased() == "bar" }
                lblNoHay.text = translation.getString("not_result_title_3") ?? "no_bares_near".localized
                lblNoHayMessage.text = translation.getString("not_result_description_3") ?? lblNoHayMessage.text

            case 3:
                // Chill out
                placesFiltered = places
                    .filter { $0.type.lowercased() == "chill_out" || $0.type.lowercased() == "chill" }
                lblNoHay.text = translation.getString("not_result_title_4") ??  "no_exclusive_near".localized
                lblNoHayMessage.text = translation.getString("not_result_description_4") ?? lblNoHayMessage.text

            default:
                // All
                placesFiltered = places
            }
            lblContribute.text = translation.getString("button_contribute") ?? lblContribute.text
        } else {
            switch tabIndex {
            case 0:
                // Featured
                eventsFiltered = events
                lblNoHay.text = "no_popular_near".localized
            case 1:
                // Discotecas
                placesFiltered = places
                    .filter { $0.type.lowercased() == "discoteca" }
                lblNoHay.text = "no_disco_near".localized
            case 2:
                // Eventos
                placesFiltered = places
                    .filter { $0.type.lowercased() == "event" || $0.type.lowercased() == "bar" }
                lblNoHay.text = "no_bares_near".localized
            case 3:
                // Chill out
                placesFiltered = places
                    .filter { $0.type.lowercased() == "chill_out" || $0.type.lowercased() == "chill" }
                lblNoHay.text = "no_exclusive_near".localized
            default:
                // All
                placesFiltered = places
            }
        }

        showPlaces(force: false)
    }

    func showPlaces(force: Bool) {
        if tabIndex == 0 {
            vNothingClose.isHidden = force || !eventsFiltered.isEmpty
        } else {
            vNothingClose.isHidden = force || !placesFiltered.isEmpty
        }
        // cvPlaces.reloadSections(IndexSet(arrayLiteral: 0))
        cvPlaces.reloadData()

        delegate?.layoutTabs()
    }

    @objc private func refreshPlaces(_ sender: Any) {
        AppSound.uiRefreshFeed.play()
        delegate?.refreshData {
            self.refreshControl.endRefreshing()
        }
    }

    @IBAction func contribute() {
        UIDevice.vibrate()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.delegate?.contribute()
        }
    }
}

extension HomeTabView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            if viewController?.banner == nil {
                return 0
            } else {
                return 1
            }
        } else {
            if tabIndex == 0 {
                return eventsFiltered.count
            } else {
                return placesFiltered.count
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Banner", for: indexPath) as? CellBanner
            if let banner = viewController?.banner {
                cell?.prepare(banner: banner)
            }
            return cell ?? UICollectionViewCell()
        } else {
            if tabIndex == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Event", for: indexPath) as? CellEvent
                cell?.prepare(event: eventsFiltered[indexPath.item], delegate: viewController)
                return cell ?? UICollectionViewCell()
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Place", for: indexPath) as? CellPlace
                cell?.prepare(place: placesFiltered[indexPath.item], delegate: viewController)
                return cell ?? UICollectionViewCell()
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: UIScreen.main.bounds.width - 40, height: 90)
        } else {
            let cellWidth = UIScreen.main.bounds.width - 40
            let picWidth = cellWidth - 16
            let picHeight = picWidth * 145 / 368
            let cellHeight = picHeight + 16
            return CGSize(width: cellWidth, height: cellHeight)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if indexPath.section == 0 {
            return
        }

        let index = indexPath.item
        if tabIndex == 0 {
            let selectedEvent = eventsFiltered[index]
            let selectedPlace = viewController?.places.first(where: { $0.id == selectedEvent.idLocal })

            self.viewController?.performSegue(withIdentifier: "Event",
                                  sender: (selectedEvent, selectedPlace,
                                           selectedEvent.idLocal, self.viewController?.locals[selectedEvent.idLocal ?? -1]))
        } else {
            let selectedPlace = placesFiltered[index]
            if let localId = selectedPlace.id {
                if let local = viewController?.locals[localId] {
                    self.viewController?.performSegue(withIdentifier: "Place", sender: local)
                } else {
                    let loading = BlurryLoadingView.showAndStart()
                    API.shared.getLocal(id: localId, place: selectedPlace) { (local, error) in
                        loading.stopAndHide()
                        if let error = error {
                            self.viewController?.show(error: error)
                            return
                        }

                        if let local = local {
                            self.viewController?.locals[localId] = local
                            self.viewController?.performSegue(withIdentifier: "Place", sender: local)
                        } else {
                            self.viewController?.showError("Incorrect room")
                        }
                    }
                }
            }
        }
    }
}
