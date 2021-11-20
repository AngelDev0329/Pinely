//
//  HomeViewController.swift
//  Pinely
//

import UIKit
import SwiftEventBus
import FirebaseAuth
import FirebaseAnalytics
import FirebaseRemoteConfig
import SwipeView

// swiftlint:disable file_length
// swiftlint:disable type_body_length
class HomeViewController: ViewController {
    @IBOutlet weak var cvTabs: UICollectionView!

    @IBOutlet weak var lblNear: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var vLocationShadow: UIView!

    @IBOutlet weak var aiLoading: UIActivityIndicatorView!

    @IBOutlet weak var svContent: SwipeView!

    var tabs: [String] = []

    var places: [Place] = []
    var events: [Event] = []

    var placesFiltered: [Place] = []
    var eventsFiltered: [Event] = []

    var locals: [Int: Local] = [:]
    var eventInfos: [Int: EventInfo] = [:]
    var eventRules: [Int: EventRules] = [:]
    var eventTickets: [Int: [Ticket]] = [:]

    var banner: Banner?

    var selectedTabIndex: Int = 0
    var tabSpacing: CGFloat = 10.0

    var preopenStaff = false
    var preopenStaffMenu = false
    var preopenStaffOnAuth = false
    var preopenStaffMenuOnAuth = false

    var remoteConfig: RemoteConfig!

    private func getLocationByIPIfNecessary() {
        let userDefaults = UserDefaults.standard
        if !userDefaults.bool(forKey: "gotLocationByIp") {
            API.shared.getIpInfo { [weak self] (ipInfo, _) in
                userDefaults.set(true, forKey: "gotLocationByIp")
                userDefaults.synchronize()

                if let ipInfo = ipInfo {
                    let fullCityName = ipInfo.location?.capital ?? ipInfo.city
                    if let cityName = fullCityName?.lowercased().folding(options: .diacriticInsensitive, locale: .current),
                       let city = City.shared.first(where: { city in
                           city.name.lowercased().folding(options: .diacriticInsensitive, locale: .current) == cityName
                       }) {
                        CityOrTown.current = city
                        self?.showTownAndUpdate()
                    } else if let latitude = ipInfo.latitude,
                              let longitude = ipInfo.longitude {
                        CityOrTown.chooseNearestTo(latitude: latitude, longitude: longitude)
                    }
                    self?.chooseLocation()
                }
            }
        }
    }

    private func processCurrentProgress() {
        PaymentProgress.current = PaymentProgress()
        if let progress = PaymentProgress.current {
            let upid = progress.upid
            let loadingView = LoadingView.showAndRun(text: "buytickets".localized, viewController: self)
            API.shared.getSaleByUpid(upid: upid) { [weak self] (sale, _) in
                PaymentProgress.reset()

                if let sale = sale {
                    API.shared.getLET(sale: sale) { [weak self] (local, event, ticket, _) in
                        loadingView?.stopAndRemove()

                        let priceTicket = ticket?.priceTicket ?? 0
                        let saleNumber = sale.number ?? 0
                        let gestionFee = ticket?.gestionFee ?? 0
                        let item = [
                            "name_local": local?.localName ?? "",
                            "name_event": event?.name ?? "",
                            "name_ticket": ticket?.name ?? ""
                        ]
                        Analytics.logEvent("purchase", parameters: [
                            "transaction_id": sale.id ?? "",
                            "value": Double(priceTicket * saleNumber + gestionFee) * 0.01,
                            "currency": sale.currency ?? "",
                            "items": [ item ]
                        ])
                        // Analytics.logEvent("ecommerce_purchase", parameters: [:])

                        let mainStoryboard = self?.storyboard ?? UIStoryboard(name: "Main", bundle: nil)
                        if let ticketQRVC = mainStoryboard.instantiateViewController(withIdentifier: "TicketQR") as? TicketQRViewController {
                            ticketQRVC.local = local
                            ticketQRVC.event = event
                            ticketQRVC.ticket = ticket
                            ticketQRVC.sale = sale

                            self?.present(ticketQRVC, animated: true, completion: nil)
                        }
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                        loadingView?.stopAndRemove()
                        let error = NetworkError.apiError(error: "charged_failed".localized)
                        self?.show(error: error)
                    }
                }
            }
        }
    }

    fileprivate func authChanged() {
        if self.preopenStaffOnAuth {
            self.preopenStaffOnAuth = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let loading = BlurryLoadingView.showAndStart()
                API.shared.loadUserInfo(force: true) { (profile, _) in
                    loading.stopAndHide()
                    self.performSegue(withIdentifier: "StartContribution", sender: profile)
                }
            }
        } else if self.preopenStaffMenuOnAuth {
            self.preopenStaffMenuOnAuth = false
            let staffStoryboard = UIStoryboard(name: "Staff", bundle: nil)
            if let initialVC = staffStoryboard.instantiateInitialViewController() {
                if let navigatorController = initialVC as? UINavigationController {
                    let firstVC = navigatorController.viewControllers[0]
                    self.tabBarController?.navigationController?.pushViewController(firstVC, animated: true)
                } else {
                    self.tabBarController?.navigationController?.pushViewController(initialVC, animated: true)
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        showTown()
        aiLoading.startAnimating()
        svContent.isHidden = true
        loadData { [weak self] in
            self?.aiLoading.stopAnimating()
            self?.svContent.isHidden = false

            self?.getLocationByIPIfNecessary()

            self?.processCurrentProgress()
        }

        SwiftEventBus.onMainThread(self, name: "townUpdated") { [weak self] _ in
            let translation = AppDelegate.translation
            if let updatingText = translation?.getString("updating_location_bar") {
                self?.lblNear.text = updatingText
                self?.lblLocation.text = ""
            }
            else{
                self?.lblNear.text = "Actualizando"
                self?.lblLocation.text = "..."
            }
            self?.showTownAndUpdate()
        }

        SwiftEventBus.onMainThread(self, name: "cancelPreopens") { [weak self] _ in
            self?.preopenStaff = false
            self?.preopenStaffOnAuth = false
            self?.preopenStaffMenu = false
            self?.preopenStaffMenuOnAuth = false
        }

        SwiftEventBus.onMainThread(self, name: "authChanged") { [weak self] _ in
            self?.authChanged()
        }

        let translation = AppDelegate.translation
        lblSearch?.text = translation?.getString("search_bar_text") ?? "searchsomething".localized
        tabs = [
            translation?.getString("tab_home_1")?.uppercased() ?? "tab.popular".localized,
            translation?.getString("tab_home_2")?.uppercased() ?? "tab.disco".localized,
            translation?.getString("tab_home_3")?.uppercased() ?? "tab.bars".localized,
            translation?.getString("tab_home_4")?.uppercased() ?? "tab.exclusive".localized
        ]

        if let remoteConfig = (UIApplication.shared.delegate as? AppDelegate)?.remoteConfig {
            let updateApp = remoteConfig.configValue(forKey: "update_app").boolValue
            print("updateApp: \(updateApp)")
            if updateApp {
                self.actualizeVersion(force: true)
            }
        }
    }

    deinit {
        SwiftEventBus.unregister(self)
    }

    private func actualizeVersion(force: Bool) {
        let alert = UIAlertController(title: "alert.onemoment".localized,
                                      message: "alert.needupdate".localized,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "button.update".localized, style: .default) { (_) in
            if let url = URL(string: "itms-apps://itunes.apple.com/app/id1524802936") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            if force {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    exit(0)
                }
            }
        })
        self.present(alert, animated: true, completion: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        calculateTabDistance()
    }

    func loadData(delegate: @escaping () -> Void) {
        API.shared.loadCities { (_) in
            if Town.current == nil {
                CityOrTown.loadCurrent()
            }
            self.showTown()
            if !UserDefaults.standard.bool(forKey: "gotLocationByIp") {
                delegate()
                return
            }

            API.shared.getRoom(cityOrTown: CityOrTown.current) { (places, events, _) in
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                   let remoteConfig = appDelegate.remoteConfig,
                   let banner = remoteConfig.configValue(forKey: "banner").stringValue,
                   let bannerDict = banner.asDict,
                   let showBanner = bannerDict.getBoolean("show_banner") {
                    if showBanner {
                        self.banner = Banner(dict: bannerDict)
                    } else {
                        self.banner = nil
                    }
                }

                self.places = places.filter {
                    ($0.status ?? 0) > 0
                }
                self.events = events.filter {
                    $0.closeSell != nil && $0.closeSell!.timeIntervalSinceNow > 0
                }

                self.filterForTab()

                delegate()
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        showTown()

        if Registrator.hasUnfinishedRegistration() {
            // Finish registration
            Registrator.finishRegistration(viewController: self)
        } else if UserDefaults.standard.bool(forKey: StorageKey.registrationUnfinishedSocial.rawValue) {
            // Finish social
            let authStoryboard = UIStoryboard(name: "Auth", bundle: nil)
            let socialRegistrationVC = authStoryboard.instantiateViewController(withIdentifier: "SocialRegistration")
            present(socialRegistrationVC, animated: true, completion: nil)
        }

        if preopenStaff {
            if Auth.auth().currentUser == nil {
                preopenStaffOnAuth = true
                preopenStaff = false
                let authSb = UIStoryboard(name: "Auth", bundle: nil)
                let authVc = authSb.instantiateInitialViewController()!
                tabBarController?.present(authVc, animated: true)

            } else {
                preopenStaff = false
                let loading = BlurryLoadingView.showAndStart()
                API.shared.loadUserInfo(force: true) { (profile, _) in
                    loading.stopAndHide()
                    self.performSegue(withIdentifier: "StartContribution", sender: profile)
                }
            }
        } else if preopenStaffMenu {
            if Auth.auth().currentUser == nil {
                preopenStaffMenuOnAuth = true
                preopenStaffMenu = false
                let authSb = UIStoryboard(name: "Auth", bundle: nil)
                let authVc = authSb.instantiateInitialViewController()!
                tabBarController?.present(authVc, animated: true)
            } else {
                preopenStaffMenu = false
                let staffStoryboard = UIStoryboard(name: "Staff", bundle: nil)
                if let initialVC = staffStoryboard.instantiateInitialViewController() {
                    if let navigationController = initialVC as? UINavigationController {
                        let firstVC = navigationController.viewControllers[0]
                        self.tabBarController?.navigationController?.pushViewController(firstVC, animated: true)
                    } else {
                        self.tabBarController?.navigationController?.pushViewController(initialVC, animated: true)
                    }
                }
            }
        }
    }

    private func showTownAndUpdate() {
        API.shared.getRoom(cityOrTown: CityOrTown.current) { (places, events, _) in
            self.showTown()
            self.places = places.filter {
                ($0.status ?? 0) > 0
            }
            self.events = events.filter {
                $0.closeSell != nil && $0.closeSell!.timeIntervalSinceNow > 0
            }
            self.filterForTab()

            if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
               let remoteConfig = appDelegate.remoteConfig,
               let banner = remoteConfig.configValue(forKey: "banner").stringValue,
               let bannerDict = banner.asDict,
               let showBanner = bannerDict.getBoolean("show_banner") {
                if showBanner {
                    self.banner = Banner(dict: bannerDict)
                } else {
                    self.banner = nil
                }
            }

            self.svContent.reloadData()
        }
    }

    private func showTown() {
        let prevLocationTitle = lblLocation.text ?? ""

        if let cityOrTown = CityOrTown.current {
            lblNear.text = "near".localized
            let name = cityOrTown.getFullName()
            lblLocation.text = "\("in".localized) \(name)"
        } else {
            // No town selected
            lblNear.text = "Actualizando"
            lblLocation.text = "..."
        }

        if lblLocation.text != prevLocationTitle {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                self?.vLocationShadow?.updateShadow()
            }
        }
    }

    private func calculateTabDistance() {
        if tabs.count <= 1 {
            return
        }

        var width: CGFloat = 0.0
        let font = AppFont.semiBold[10]
        tabs.forEach { (title) in
            width += title.width(withConstrainedHeight: 28, font: font)
        }

        let widthCV = cvTabs.bounds.width - 56
        let diff = widthCV - width
        if diff < 10 {
            tabSpacing = 10.0
            cvTabs.isScrollEnabled = true
        } else {
            tabSpacing = diff / CGFloat(tabs.count - 1)
            cvTabs.isScrollEnabled = false
        }
    }

    private func preparePlaceVC(_ sender: Any?, _ placeVC: PlaceViewController) {
        if let local = sender as? Local {
            placeVC.local = local
        }
        if let place = sender as? Place {
            placeVC.place = place
        }
    }

    private func prepareEventVC(_ sender: Any?, _ eventVC: EventViewController) {
        let args = sender as? (Event?, Place?, Int?, Local?)
        eventVC.event = args?.0
        eventVC.place = args?.1
        eventVC.placeId = args?.2
        eventVC.local = args?.3

        if let eventId = args?.0?.id {
            if let eventInfo = self.eventInfos[eventId] {
                eventVC.eventInfo = eventInfo
            }
            if let eventRules = self.eventRules[eventId] {
                eventVC.eventRules = eventRules
            }
            if let tickets = self.eventTickets[eventId] {
                eventVC.tickets = tickets
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let placeVC = segue.destination as? PlaceViewController {
            preparePlaceVC(sender, placeVC)
        } else if let eventVC = segue.destination as? EventViewController {
            prepareEventVC(sender, eventVC)
        } else if let contributeVC = segue.destination as? ContributeViewController {
            contributeVC.predefinedCategory = tabs[selectedTabIndex].lowercased().capitalized
        } else if let startCollaborationVC = segue.destination as? StartCollaborationViewController {
            startCollaborationVC.delegate = self
            if let profile = sender as? Profile {
                startCollaborationVC.username = profile.name ?? ""
            }
        }
    }

    @IBAction func chooseLocation() {
        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.performSegue(withIdentifier: "ChooseLocation", sender: self)
        }
    }

    func showTabOrSearch() {
        let searchRequest = tfSearch?.text ?? ""
        if searchRequest.isEmpty {
            filterForTab()
        } else {
            let searchRequestLC = searchRequest.lowercased().folding(options: .diacriticInsensitive, locale: .current)
            self.buildFilteredPlacesList(searchRequestLC)
            self.buildFilteredEventsList(searchRequestLC)
            svContent.reloadData()
        }
    }

    func buildFilteredPlacesList(_ searchRequestLC: String) {
        placesFiltered = places.filter { (place) -> Bool in
            place.name.lowercased()
                .folding(options: .diacriticInsensitive, locale: .current)
                .contains(searchRequestLC) ||
            place.subTitle.lowercased().contains(searchRequestLC)
        }
    }

    func buildFilteredEventsList(_ searchRequestLC: String) {
        eventsFiltered = events.filter { (event) -> Bool in
            event.name.lowercased()
                .folding(options: .diacriticInsensitive, locale: .current)
                .contains(searchRequestLC) ||
            (event.subTitle ?? "").lowercased().contains(searchRequestLC)
        }
    }
}
