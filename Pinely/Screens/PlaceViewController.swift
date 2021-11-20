//
//  PlaceViewController.swift
//  Pinely
//

import UIKit
import Kingfisher
import Reachability
import FirebaseAuth
import AXPhotoViewer
import SwiftEventBus
import SwipeView
import FirebaseAnalytics

// swiftlint:disable type_body_length
class PlaceViewController: ViewController {
    @IBOutlet weak var svPlaceTabs: SwipeView!

    @IBOutlet weak var ivCoverGif: UIImageView!
    @IBOutlet weak var ivCover: UIImageView!
    @IBOutlet weak var ivLogoGif: UIImageView!
    @IBOutlet weak var ivLogo: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var lblLocation: UILabel!

    @IBOutlet weak var btnEvents: UIButton!
    @IBOutlet weak var btnPhotos: UIButton!
    @IBOutlet weak var btnInfo: UIButton!
    @IBOutlet weak var vEvents: UIView!
    @IBOutlet weak var vPhotos: UIView!
    @IBOutlet weak var vInfo: UIView!

    @IBOutlet weak var btnShare: UIButton!

    @IBOutlet weak var lcBottom: NSLayoutConstraint!

    @IBOutlet weak var aiLoading: UIActivityIndicatorView!

    @IBOutlet weak var vMessageContainer: UIView!
    @IBOutlet weak var vMessagePanel: UIView!
    @IBOutlet weak var lcMessageBottom: NSLayoutConstraint!

    var tabBarHeight: CGFloat = 0

    var placeId: Int?
    var place: Place?
    var local: Local?
    var events: [Event] {
        if local?.areSelling == true {
            return local?.events ?? []
        } else {
            return []
        }
    }

    var eventInfos: [Int: EventInfo] = [:]
    var eventRules: [Int: EventRules] = [:]
    var eventTickets: [Int: [Ticket]] = [:]

    var loaded = false

    var photoSelectionPurpose = ""

    var photoToDelete: PhotoFakeOrReal?

    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            let gifImage = try UIImage(gifName: "skeleton_effect.gif")
            ivCoverGif.setGifImage(gifImage)
            ivCoverGif.isHidden = false
            ivCover.isHidden = true
        } catch {
            print(error)
        }

        do {
            let gifImage = try UIImage(gifName: "skeleton_effect_avatar.gif")
            ivLogoGif.setGifImage(gifImage)
            ivLogoGif.isHidden = false
            ivLogo.isHidden = true
        } catch {
            print(error)
        }

        if let place = place,
           placeId == nil {
            self.placeId = place.id
        }
        loadOrShow()

        SwiftEventBus.post("cancelPreopens")

        if let translation = AppDelegate.translation {
            btnEvents.setTitleFromTranslation("local_option_1", translation)
            btnPhotos.setTitleFromTranslation("local_option_2", translation)
            btnInfo.setTitleFromTranslation("local_option_3", translation)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        lcBottom.constant = tabBarHeight
        view.layoutIfNeeded()
    }

    private func setPictures() {
        if let local = self.local,
           let thumbUrl = local.thumb,
           let url = URL(string: thumbUrl) {
            if ivCoverGif.isAnimatingGif() {
                ivCoverGif.stopAnimatingGif()
                ivCoverGif.image = nil
                ivCoverGif.isHidden = true
            }
            self.ivCover.kf.setImage(with: url)
            self.ivCover.isHidden = false
        }

        if let local = self.local,
           let avatarUrl = local.avatar,
           let url = URL(string: avatarUrl) {
            if ivLogoGif.isAnimatingGif() {
                ivLogoGif.stopAnimatingGif()
                ivLogoGif.image = nil
                ivLogoGif.isHidden = true
            }
            self.ivLogo.kf.setImage(with: url)
            self.ivLogo.isHidden = false
        }
    }

    private func showLocal(_ local: Local) {
        self.aiLoading.stopAnimating()
        setPictures()

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
        svPlaceTabs.visibleItemViews?
            .compactMap { $0 as? PlaceTabView }
            .forEach {
                $0.prepare(tabIndex: $0.tabIndex, viewController: self,
                           place: place, local: local, events: events,
                           loaded: true, delegate: self)
            }
    }

    func loadOrShow() {
        if let local = self.local {
            showLocal(local)
        } else if let placeId = placeId ?? place?.id {
            setPictures()
            if let place = self.place {
                lblTitle.text = place.name
                lblSubTitle.text = place.subTitle
                lblLocation.text = CityOrTown.current?.getFullName() ?? ""
            } else {
                lblTitle.text = ""
                lblSubTitle.text = ""
                lblLocation.text = ""
            }
            API.shared.getLocal(id: placeId, place: place) { (local, error) in
                self.aiLoading.stopAnimating()
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
            lblTitle.text = ""
            lblSubTitle.text = ""
            lblLocation.text = ""
            showError("Unknown room") {
                self.goBack()
            }
        }
    }

    @IBAction func showEvents() {
        showEventsTab()
        svPlaceTabs.scrollToItem(at: 0, duration: 0.3)
    }

    func showEventsTab() {
        btnEvents.setTitleColor(UIColor(named: "MainForegroundColor")!, for: .normal)
        btnPhotos.setTitleColor(UIColor(hex: 0x7B7B7B)!, for: .normal)
        btnInfo.setTitleColor(UIColor(hex: 0x7B7B7B)!, for: .normal)
        vEvents.isHidden = false
        vPhotos.isHidden = true
        vInfo.isHidden = true
    }

    @IBAction func showPhotos() {
        showPhotosTab()
        svPlaceTabs.scrollToItem(at: 1, duration: 0.3)
    }

    func showPhotosTab() {
        btnEvents.setTitleColor(UIColor(hex: 0x7B7B7B)!, for: .normal)
        btnPhotos.setTitleColor(UIColor(named: "MainForegroundColor")!, for: .normal)
        btnInfo.setTitleColor(UIColor(hex: 0x7B7B7B)!, for: .normal)
        vEvents.isHidden = true
        vPhotos.isHidden = false
        vInfo.isHidden = true
    }

    @IBAction func showInfo() {
        showInfoTab()
        svPlaceTabs.scrollToItem(at: 2, duration: 0.3)
    }

    func showInfoTab() {
        btnEvents.setTitleColor(UIColor(hex: 0x7B7B7B)!, for: .normal)
        btnPhotos.setTitleColor(UIColor(hex: 0x7B7B7B)!, for: .normal)
        btnInfo.setTitleColor(UIColor(named: "MainForegroundColor")!, for: .normal)
        vEvents.isHidden = true
        vPhotos.isHidden = true
        vInfo.isHidden = false
    }

    @IBAction func share() {
        guard let roomId = place?.id else {
            return
        }

        let thumbUrl = place?.thumbUrl ?? local?.thumb ?? ""
        let roomName = place?.name ?? ""

        Analytics.logEvent("share_local", parameters: [
            "id_event": roomId,
            "name_event": roomName
        ])

        guard let link = ShareLink.room(roomId: roomId).url else {
            return
        }
        let imageUrl = URL(string: thumbUrl)

        generate(link: link,
                 title: "share.place.title".localized.replacingOccurrences(of: "$roomName", with: roomName),
                 descriptionText: "share.place.description".localized.replacingOccurrences(of: "$roomName", with: roomName),
                 imageURL: imageUrl) { [weak self] (url) in
            guard let self = self else {
                return
            }

            let text = self.createShareText(
                stringId: "share.place.text", eventName: nil,
                roomName: roomName, url: url)

            self.shareText(text, sourceView: self.btnShare)
        }
    }

    @IBAction func swipedRight() {
        self.goBack()
    }

    @IBAction func addPhoto() {
        UIDevice.vibrate()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.photoSelectionPurpose = "addPhoto"
            self.selectPhotoFromGallery(croppingStyle: .default)
        }
    }

    @IBAction func showMessagePanel() {
        tabBarController?.tabBar.layer.zPosition = -1
        vMessagePanel.layer.zPosition = 1

        lcMessageBottom.constant = -500
        view.layoutIfNeeded()

        vMessageContainer.alpha = 0.0
        vMessageContainer.isHidden = false

        lcMessageBottom.constant = -30 - (tabBarController?.tabBar.bounds.height ?? 0)
        UIView.animate(withDuration: 0.3) {
            self.vMessageContainer.alpha = 1.0
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.tabBarController?.tabBar.isHidden = true
        }
    }

    @IBAction func hideMessagePanel() {
        self.tabBarController?.tabBar.isHidden = false
        lcMessageBottom.constant = -500

        UIView.animate(withDuration: 0.3) {
            self.vMessageContainer.alpha = 0.0
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.vMessageContainer.isHidden = true
            self.tabBarController?.tabBar.layer.zPosition = 0
        }
    }

    @IBAction func selectScreenshot() {
        UIDevice.vibrate()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.photoSelectionPurpose = "selectScreenshot"
            self.selectPhotoFromGallery(croppingStyle: .default)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let eventVC = segue.destination as? EventViewController {
            eventVC.local = local
            if var event = sender as? Event {
                if event.idLocal == nil {
                    event.idLocal = self.placeId ?? self.place?.id
                }
                eventVC.event = event
                if let eventId = event.id {
                    eventVC.eventInfo = self.eventInfos[eventId]
                    eventVC.eventRules = self.eventRules[eventId]
                    eventVC.tickets = self.eventTickets[eventId] ?? []
                }
            }
        }
    }

    override var preferredStatusBarStyleInternal: UIStatusBarStyle {
        .lightContent
    }

    static func deleteFileIfExist(_ url: URL?) {
        if let url = url {
            try? FileManager.default.removeItem(at: url)
        }
    }

    private func addPhotoAllowed(image: UIImage, localId: Int) {
        let jpeg = image.jpegData(compressionQuality: 0.8)!
        let currentTimestamp = Int64(Date().timeIntervalSince1970)
        var fileToDelete: URL?
        let filename = URL.getFileInDocumentsDirectory("\(currentTimestamp).jpg")
        _ = try? jpeg.write(to: filename)
        fileToDelete = filename
        self.local?.photos.insert(Photo(urlLocal: filename.absoluteString), at: 0)
        self.svPlaceTabs.reloadData()

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
                        Kingfisher.ImageDownloader.default.downloadImage(with: url, options: [],
                                                                         completionHandler: { [weak self] (result) in
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
    }

    fileprivate func addPhotoFake(image: UIImage) {
        if let reachability = try? Reachability(),
           reachability.connection != .unavailable {
            DispatchQueue.global().asyncAfter(deadline: .now() + 3) { [weak self] in
                guard let safeSelf = self else {
                    return
                }

                let jpeg = image.jpegData(compressionQuality: 0.8)!
                let currentTimestamp = Int64(Date().timeIntervalSince1970)
                let filename = URL.getFileInDocumentsDirectory("\(currentTimestamp).jpg")
                _ = try? jpeg.write(to: filename)

                let afterPhoto = safeSelf.local?.photos.first(where: { $0.URLFull?.starts(with: "http") == true })?.URLFull
                let fakePhoto = PhotoFakeLocal(url: filename.absoluteString, after: afterPhoto)
                safeSelf.local?.photos.insert(fakePhoto, at: 0)

                var allFake = PhotoFakeLocal.load()
                allFake.append(fakePhoto)
                PhotoFakeLocal.save(photos: allFake)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                    self?.loadOrShow()
                }
            }
        }
    }

    func addPhoto(_ image: UIImage) {
        let localId = self.placeId ?? self.place?.id ?? 0
        API.shared.userCanUploadPhotos { [weak self] (canUploadPhotos, _) in
            if canUploadPhotos {
                self?.addPhotoAllowed(image: image, localId: localId)
            } else {
                self?.addPhotoFake(image: image)
            }
        }
    }

    fileprivate func selectScreenshot(_ image: UIImage) {
        hideMessagePanel()

        let loadingView = LoadingView.showAndRun(text: "Estamos analizando tu\ncaptura, un momento...",
                                                 viewController: self)
        API.shared.userCanUploadPhotos { (canUploadPhotos, _) in
            if canUploadPhotos {
                let localId = self.placeId ?? self.place?.id ?? 0
                API.shared.uploadPhotoLocalContribution(localId: localId, image: image) { (_, error) in
                    loadingView?.stopAndRemove()
                    if let error = error {
                        self.show(error: error)
                        return
                    }

                    loadingView?.stopAndRemove()
                }
            } else {
                if let reachability = try? Reachability(),
                   reachability.connection == .unavailable {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        loadingView?.stopAndRemove()
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                        loadingView?.stopAndRemove()
                    }
                }
            }
        }
    }

    override func photoSelected(image: UIImage?) {
        guard let image = image else {
            return
        }

        switch photoSelectionPurpose {
        case "addPhoto":
            addPhoto(image)

        case "selectScreenshot":
            selectScreenshot(image)

        default:
            break
        }

    }
}
