//
//  StaffPlaceEditViewController.swift
//  Pinely
//

import UIKit
import Kingfisher
import SwiftEventBus

// swiftlint:disable type_body_length
class StaffPlaceEditViewController: ViewController {
    @IBOutlet weak var cvEvents: UICollectionView!
    @IBOutlet weak var ivCover: UIImageView!
    @IBOutlet weak var ivCoverGif: UIImageView!
    @IBOutlet weak var ivLogo: UIImageView!
    @IBOutlet weak var ivLogoGif: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var lblLocation: UILabel!

    @IBOutlet weak var btnEvents: UIButton!
    @IBOutlet weak var btnPhotos: UIButton!
    @IBOutlet weak var btnInfo: UIButton!
    @IBOutlet weak var vEvents: UIView!
    @IBOutlet weak var vPhotos: UIView!
    @IBOutlet weak var vInfo: UIView!

    var swipeLeftDetector: UISwipeGestureRecognizer!
    var swipeRightDetector: UISwipeGestureRecognizer!

    var selectedTabIndex: Int = 0
    var tabBarHeight: CGFloat = 0

    var place: Place?
    var local: Local?
    var events: [Event] {
        local?.events ?? []
    }

    var photoSelectionPurpose = ""

    var placeId: Int? {
        place?.id
    }

    var loaded = false
    var changed = false

    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        swipeLeftDetector = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        swipeLeftDetector.direction = .left

        swipeRightDetector = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        swipeRightDetector.direction = .right

        cvEvents.addGestureRecognizer(swipeLeftDetector)
        cvEvents.addGestureRecognizer(swipeRightDetector)

        cvEvents.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)

        lblTitle.text = place?.name ?? ""
        lblSubTitle.text = place?.subTitle ?? ""

        SwiftEventBus.onMainThread(self, name: "localChanged") { (_) in
            self.local = nil
            self.loadOrShow()
        }

        loadOrShow()
    }

    deinit {
        SwiftEventBus.unregister(self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let navigationController = self.navigationController {
            self.navigationController?.viewControllers = navigationController.viewControllers.filter {
                !($0 is StaffCreateLocalViewController) && !($0 is StaffChooseLocationViewController)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if changed {
            SwiftEventBus.post("localsUpdates")
        }
    }

    private func setPictures() {
        if let local = self.local,
           let thumbUrl = local.thumb,
            let url = URL(string: thumbUrl) {
            if ivCoverGif.isAnimatingGif() {
                ivCoverGif.stopAnimatingGif()
                ivCoverGif.image = nil
            }
            if thumbUrl == "https://storage.googleapis.com/pinely-clients/avatar-rooms/default-banner-client.png" {
                ivCover.image = #imageLiteral(resourceName: "850x425px")
            } else {
                ivCover.kf.setImage(with: url)
            }
        } else {
            do {
                let gifImage = try UIImage(gifName: "skeleton_effect.gif")
                ivCoverGif.setGifImage(gifImage)
            } catch {
                print(error)
            }
        }

        if let local = self.local,
           let avatarUrl = local.avatar,
            let url = URL(string: avatarUrl) {
            if ivLogoGif.isAnimatingGif() {
                ivLogoGif.stopAnimatingGif()
                ivLogoGif.image = nil
                ivLogoGif.isHidden = true
            }
            if avatarUrl == "https://storage.googleapis.com/pinely-clients/avatar-rooms/default-avatar-white.png" {
                ivLogo.image = #imageLiteral(resourceName: "512x512px")
            } else {
                ivLogo.kf.setImage(with: url)
            }
            ivLogo.isHidden = false
        } else {
            do {
                let gifImage = try UIImage(gifName: "skeleton_effect_avatar.gif")
                ivLogoGif.setGifImage(gifImage)
                ivLogoGif.isHidden = false
                ivLogo.isHidden = true
            } catch {
                print(error)
            }
        }
    }

    private func loadOrShow() {
        if let local = self.local {
            self.setPictures()

            lblTitle.text = local.localName
            lblSubTitle.text = local.subTitle

            let cityOrTown: CityOrTown?
            if let idTown = local.localTownId {
                cityOrTown = Town.shared.first(where: { $0.id == idTown })
            } else if let idCity = local.localCityId {
                cityOrTown = City.shared.first(where: { $0.id == idCity })
            } else {
                cityOrTown = nil
            }

            if let cityOrTown = cityOrTown {
                lblLocation.text = cityOrTown.getFullName()
            } else {
                let components = [local.localTown ?? "", local.localCountry ?? "", local.localCountry ?? ""]
                let locName = components
                    .filter { !$0.isEmpty && $0.lowercased().contains("null") }
                    .joined(separator: ", ")
                lblLocation.text = locName
            }

            self.loaded = true
            cvEvents.reloadData()
        } else if let placeId = placeId ?? place?.id {
            setPictures()

            lblTitle.text = ""
            lblSubTitle.text = ""
            lblLocation.text = ""
            let loading = BlurryLoadingView.showAndStart()
            API.shared.getLocal(id: placeId, place: place) { (local, error) in
                loading.stopAndHide()
                if let error = error {
                    self.show(error: error)
                    return
                }

                self.local = local
                if self.local != nil {
                    self.loadOrShow()
                }
            }
        } else {
            lblTitle.text = "Enter title"
            lblSubTitle.text = "Enter subtitle"
            lblLocation.text = "Choose location"
            setPictures()
        }
    }

    @objc private func refresh(_ sender: Any?) {
        AppSound.uiRefreshFeed.play()
        self.refreshControl.endRefreshing()
    }

    @objc func handleSwipeGesture(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .right {
            if selectedTabIndex > 0 {
                UIView.animate(withDuration: 0.1) {
                    self.cvEvents.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width, y: 0)
                } completion: { _ in
                    self.selectedTabIndex -= 1
                    self.showActualTab()
                    self.cvEvents.transform = CGAffineTransform(translationX: -UIScreen.main.bounds.width, y: 0)
                    UIView.animate(withDuration: 0.1) {
                        self.cvEvents.transform = CGAffineTransform(translationX: 0, y: 0)
                    }
                }
            }
        } else if gesture.direction == .left {
            if selectedTabIndex < 2 {
                UIView.animate(withDuration: 0.1) {
                    self.cvEvents.transform = CGAffineTransform(translationX: -UIScreen.main.bounds.width, y: 0)
                } completion: { _ in
                    self.selectedTabIndex += 1
                    self.showActualTab()
                    self.cvEvents.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width, y: 0)
                    UIView.animate(withDuration: 0.1) {
                        self.cvEvents.transform = CGAffineTransform(translationX: 0, y: 0)
                    }
                }
            }
        }
    }

    func showActualTab() {
        switch selectedTabIndex {
        case 0: showEvents()
        case 1: showPhotos()
        case 2: showInfo()
        default: return
        }
    }

    @IBAction func showEvents() {
        cvEvents.refreshControl = refreshControl
        btnEvents.setTitleColor(UIColor.black, for: .normal)
        btnPhotos.setTitleColor(UIColor(hex: 0x7B7B7B)!, for: .normal)
        btnInfo.setTitleColor(UIColor(hex: 0x7B7B7B)!, for: .normal)
        vEvents.isHidden = false
        vPhotos.isHidden = true
        vInfo.isHidden = true
        selectedTabIndex = 0
        cvEvents.reloadData()
    }

    @IBAction func showPhotos() {
        cvEvents.refreshControl = refreshControl
        btnEvents.setTitleColor(UIColor(hex: 0x7B7B7B)!, for: .normal)
        btnPhotos.setTitleColor(UIColor.black, for: .normal)
        btnInfo.setTitleColor(UIColor(hex: 0x7B7B7B)!, for: .normal)
        vEvents.isHidden = true
        vPhotos.isHidden = false
        vInfo.isHidden = true
        selectedTabIndex = 1
        cvEvents.reloadData()
    }

    @IBAction func showInfo() {
        cvEvents.refreshControl = nil
        btnEvents.setTitleColor(UIColor(hex: 0x7B7B7B)!, for: .normal)
        btnPhotos.setTitleColor(UIColor(hex: 0x7B7B7B)!, for: .normal)
        btnInfo.setTitleColor(UIColor.black, for: .normal)
        vEvents.isHidden = true
        vPhotos.isHidden = true
        vInfo.isHidden = false
        selectedTabIndex = 2
        cvEvents.reloadData()
    }

    @IBAction func swipedRight() {
        self.goBack()
    }

    @IBAction func editTitle() {
        self.changed = true
        self.performSegue(withIdentifier: "StaffEditLocal", sender: nil)
    }

    @IBAction func editSubtitle() {
        self.changed = true
        self.performSegue(withIdentifier: "StaffEditLocal", sender: nil)
    }

    @IBAction func editLocation() {
        self.changed = true
        self.performSegue(withIdentifier: "StaffEditLocal", sender: nil)
    }

    @IBAction func editLogo() {
        self.changed = true
        performSegue(withIdentifier: "StaffEditEventLogo", sender: self)
    }

    @IBAction func addPhoto() {
        UIDevice.vibrate()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.photoSelectionPurpose = "addPhoto"
            self.selectPhotoFromGallery(croppingStyle: .default)
        }
    }

    override func photoSelected(image: UIImage?) {
        guard let image = image else { return }

        switch photoSelectionPurpose {
        case "addPhoto":
            let localId = self.placeId ?? self.place?.id ?? 0

            let jpeg = image.jpegData(compressionQuality: 0.8)!
            let currentTimestamp = Int64(Date().timeIntervalSince1970)
            var fileToDelete: URL?
            let filename = URL.getFileInDocumentsDirectory("\(currentTimestamp).jpg")
            _ = try? jpeg.write(to: filename)
            fileToDelete = filename
            self.local?.photos.insert(Photo(urlLocal: filename.absoluteString), at: 0)
            self.cvEvents.reloadData()

            API.shared.uploadPhotoLocal(localId: localId, image: image) { [weak self] (_, error) in
                if let error = error {
                    PlaceViewController.deleteFileIfExist(fileToDelete)
                    self?.show(error: error)
                    return
                }

                if let place = self?.place {
                    API.shared.getLocal(id: localId, place: place) { [weak self] (local, _) in
                        PlaceViewController.deleteFileIfExist(fileToDelete)
                        if local != nil,
                           let urlString = local?.photos.first?.URLThumb,
                           let url = URL(string: urlString) {
                            Kingfisher.ImageDownloader.default.downloadImage(with: url, options: [], completionHandler: { [weak self] (result) in
                                switch result {
                                case .success(let imageLoadingResult):
                                    ImageCache.default.store(imageLoadingResult.image, forKey: url.absoluteString)

                                default:
                                    break
                                }
                                self?.local = local
                                self?.loadOrShow()
                            })
                        }
                    }
                } else {
                    PlaceViewController.deleteFileIfExist(fileToDelete)
                }
            }

        default:
            break
        }

    }

    override var preferredStatusBarStyleInternal: UIStatusBarStyle {
        .lightContent
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let staffEditLocalVC = segue.destination as? StaffEditLocalViewController {
            staffEditLocalVC.local = local
            staffEditLocalVC.place = place
        } else if let staffEditEventLogoVC = segue.destination as? StaffEditEventLogoViewController {
            staffEditEventLogoVC.idLocal = place!.id
        } else if let staffChangeCoverVC = segue.destination as? StaffChangeCoverViewController {
            staffChangeCoverVC.idLocal = place!.id
        } else if let staffEventEditVC = segue.destination as? StaffEventEditViewController {
            staffEventEditVC.placeId = place!.id
            staffEventEditVC.place = place
            staffEventEditVC.local = local
            if let event = sender as? Event {
                staffEventEditVC.event = event
            }
        }
    }

}
