//
//  API.swift
//  Pinely
//

import Foundation
import FirebaseAuth
import OneSignal

// swiftlint:disable type_body_length
// swiftlint:disable file_length
class API: Network {
    static let shared = API()

    func getIpInfo(delegate: @escaping (_ ipInfo: IpInfo?, _ error: Error?) -> Void) {
        postObjectCf(useCache: false, route: .ipInformationUser, args: [:]) { (result, error) in
            if let error = error {
                delegate(nil, error)
                return
            }

            if let ipInfo = IpInfo(dict: result) {
                delegate(ipInfo, nil)
            } else {
                delegate(nil, NetworkError.apiError(error: "Incorrect server response (ip)"))
            }
        }
    }

    func getUserToken(delegate: @escaping (_ userToken: String?, _ error: Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            delegate(nil, NetworkError.unauthenticated)
            return
        }

        user.getIDTokenResult(forcingRefresh: true, completion: { (firebaseToken, error) in
            if let error = error {
                delegate(nil, error)
            } else if let firebaseToken = firebaseToken?.token {
                self.getUserToken(firebaseToken: firebaseToken, delegate: delegate)
            } else {
                delegate(nil, NetworkError.apiError(error: "Unknown error"))
            }
        })
    }

    func getUserToken(firebaseToken: String, delegate: @escaping (_ userToken: String?, _ error: Error?) -> Void) {
        postObjectCf(useCache: false, route: .getTokenUser, args: ["idToken": firebaseToken]) { (result, error) in
            if let error = error {
                delegate(nil, error)
            } else if result.getInt("success") == 1,
                let userToken = result.getString("userToken") {
                if let user = Auth.auth().currentUser {
                    API.userTokens[user.uid] = userToken
                }
                delegate(userToken, nil)
            } else {
                delegate(nil, NetworkError.apiError(
                    error: result.getString("error") ??
                    "error.errorCreatingAccount".localized))
            }
        }
    }

    func registerUser(ipInfo: IpInfo?, firstName: String, lastName: String,
                      email: String, mobilePhone: String?, dateOfBirth: Date?,
                      delegate: @escaping (_ error: Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            delegate(NetworkError.unauthenticated)
            return
        }

        var args: [String: Any] = [
            "uid": uid,
            "name": firstName,
            "lastName": lastName,
            "email": email
        ]

        if let dateOfBirth = dateOfBirth {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateString = dateFormatter.string(from: dateOfBirth)
            args["dateOfBirth"] = dateString
        }

        if let mobilePhone = mobilePhone {
            args["mobilePhone"] = mobilePhone
        }

        if let ipInfo = ipInfo {
            args["ip"] = ipInfo.ip
            if let latitude = ipInfo.latitude {
                args["lat"] = latitude
            }
            if let longitude = ipInfo.longitude {
                args["lng"] = longitude
            }
        }

        self.postObjectCf(useCache: false, route: .registerNewUser, args: args) { (result, error) in
            if let error = error {
                delegate(error)
            } else if result.getInt("success") == 1 {
                delegate(nil)
            } else {
                delegate(NetworkError.apiError(error: result.getString("error") ??
                                               "error.errorCreatingAccount".localized))
            }
        }
    }

    func registerUser(firstName: String, lastName: String,
                      email: String, mobilePhone: String?, dateOfBirth: Date?,
                      delegate: @escaping (_ error: Error?) -> Void) {
        getIpInfo { [weak self] (ipInfo, _) in
            self?.registerUser(ipInfo: ipInfo, firstName: firstName, lastName: lastName,
                               email: email, mobilePhone: mobilePhone,
                               dateOfBirth: dateOfBirth, delegate: delegate)
        }
    }

    func finishRegistration(uid: String, firstName: String, lastName: String,
                            email: String, mobilePhone: String, dateOfBirth: Date,
                            delegate: @escaping (_ error: Error?) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: dateOfBirth)

        let args: [String: Any] = [
            "uid": uid,
            "name": firstName,
            "lastName": lastName,
            "email": email,
            "mobilePhone": mobilePhone,
            "dateOfBirth": dateString
        ]

        postObjectJs(useCache: false, route: .finishRegistration, args: args) { (result, error) in
            if let error = error {
                delegate(error)
            } else if result.getInt("success") == 1 {
                delegate(nil)
            } else {
                delegate(NetworkError.apiError(error: result.getString("error") ??
                                               "error.errorCreatingAccount".localized))
            }
        }
    }

    func checkUser(uid: String, delegate: @escaping (_ exists: Bool, _ error: Error?) -> Void) {
        postObjectJs(useCache: false, route: .checkClient, args: ["uid": uid]) { (result, error) in
            if let error = error {
                delegate(false, error)
            } else if result.getInt("success") == 1 {
                delegate(result.getInt("exists") ?? 0 > 0, nil)
            } else {
                delegate(false, NetworkError.apiError(error: result.getString("error") ??
                                                      "error.checkError".localized))
            }
        }
    }

    private func getRoomCity(_ args: [String: Any], _ delegate: @escaping ([Place], [Event], Error?) -> Void) {
        getObjectJs(useCache: false, route: .room, args: args) { (result, error) in
            if let error = error {
                delegate([], [], error)
                return
            }

            let resultsArr = result["results"] as? [Any] ?? []

            let rooms = resultsArr
                .compactMap {
                    $0 as? [String: Any]
                }
                .map {
                    Place(dict: $0)
                }
                .sorted { (place0, place1) -> Bool in
                    place0.position < place1.position
                }
            delegate(rooms, [], nil)
        }
    }

    private func getRoomTown(_ args: [String: Any], _ delegate: @escaping ([Place], [Event], Error?) -> Void) {
        getObjectJs(useCache: false, route: .room, args: args) { (result, error) in
            if let error = error {
                delegate([], [], error)
                return
            }

            let locals = result["locals"] as? [Any] ?? []
            let rooms = locals
                .compactMap {
                    $0 as? [String: Any]
                }
                .map {
                    Place(dict: $0)
                }
                .sorted { (place0, place1) -> Bool in
                    place0.position < place1.position
                }
            let events = result["events"] as? [Any] ?? []
            let roomEvents = events
                .compactMap {
                    $0 as? [String: Any]
                }
                .map {
                    Event(dict: $0)
                }
                .sorted { (event0, event1) -> Bool in
                    event0.position < event1.position
                }
            delegate(rooms, roomEvents, nil)
        }
    }

    func getRoom(cityOrTown: CityOrTown?, delegate: @escaping (_ rooms: [Place], _ events: [Event], _ error: Error?) -> Void) {
        var args: [String: Any] = [:]
        var isTown = false
        if let town = cityOrTown as? Town {
            if let idCity = town.idCity {
                args["idCity"] = idCity
                if let idCountry = town.city?.idCountry {
                    args["idCountry"] = idCountry
                }
            }
            args["idTown"] = town.id
            isTown = true
        } else if let city = cityOrTown as? City {
            args["idCity"] = city.id
            if let idCountry = city.idCountry {
                args["idCountry"] = idCountry
            }
        }

        if !isTown {
            getRoomCity(args, delegate)
        } else {
            getRoomTown(args, delegate)
        }
    }

    private func parseTowns(_ townArr: [Any]) {
        for townAny in townArr {
            guard let townDict = townAny as? [String: Any] else { continue }

            let town = Town(dict: townDict)
            Town.shared.append(town)
        }
    }

    private func parseCities(_ cityArr: [Any]) {
        for cityAny in cityArr {
            guard let cityDict = cityAny as? [String: Any] else { continue }

            let city = City(dict: cityDict)
            City.shared.append(city)

            guard let townArr = cityDict["towns"] as? [Any] else { continue }

            self.parseTowns(townArr)
        }
    }

    private func parseCountries(_ resultsArr: [Any]) {
        for countryAny in resultsArr {
            guard let countryDict = countryAny as? [String: Any] else { continue }

            let country = Country(dict: countryDict)
            Country.shared.append(country)

            guard let cityArr = countryDict["cities"] as? [Any] else { continue }

            self.parseCities(cityArr)
        }
    }

    func loadCities(delegate: @escaping (_ error: Error?) -> Void) {
        getObjectJs(useCache: false, route: .location, args: [:]) { (result, error) in
            if let error = error {
                delegate(error)
                return
            }

            Country.shared = []
            City.shared = []
            Town.shared = []

            let resultsArr = result["results"] as? [Any] ?? []

            self.parseCountries(resultsArr)

            delegate(nil)
        }
    }

    func contributionRequest(name: String, category: String, countryId: Int,
                             cityId: Int, townId: Int?, delegate: @escaping (_ error: Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            delegate(NetworkError.unauthenticated)
            return
        }

        if let userToken = Profile.userToken ?? API.userTokens[uid] {
            var args: [String: Any] = [
                "name": name,
                "category": category,
                "countrie_id": countryId,
                "city_id": cityId,
                "UID": uid,
                "user_token": userToken
            ]
            if let townId = townId {
                args["town_id"] = townId
            }
            postObjectCf(useCache: false, route: .contributionRequests, args: args) { (_, error) in
                delegate(error)
            }
        } else {
            getUserToken { userToken, error in
                if let error = error {
                    delegate(error)
                } else if let userToken = userToken {
                    Profile.userToken = userToken
                    API.userTokens[uid] = userToken
                    self.contributionRequest(name: name, category: category, countryId: countryId, cityId: cityId, townId: townId, delegate: delegate)
                } else {
                    delegate(NetworkError.apiError(error: "Can't get user token"))
                }
            }
        }
    }

    func getUsername(delegate: @escaping (_ username: String?, _ error: Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            delegate(nil, NetworkError.unauthenticated)
            return
        }

        let args: [String: Any] = [
            "UID": uid
        ]
        postObjectCf(useCache: true, route: .usernameProfileCheck, args: args) { (result, error) in
            if let error = error {
                delegate(nil, error)
                return
            }

            let username = result.getString("username")
            let msg = result.getString("msg")

            if let msg = msg, (username ?? "").isEmpty {
                delegate(nil, NetworkError.apiError(error: msg))
            } else {
                delegate(username ?? "", nil)
            }
        }
    }

    func getWalletAmount(delegate: @escaping (_ amount: Wallet?, _ error: Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            delegate(nil, NetworkError.unauthenticated)
            return
        }

        let userToken = Profile.userToken ?? API.userTokens[uid]
        if userToken == nil {
            getUserStatus { _, token, error in
                if let error = error {
                    delegate(nil, error)
                } else if token != nil {
                    Profile.userToken = token
                    self.getWalletAmount(delegate: delegate)
                } else {
                    delegate(nil, NetworkError.apiError(error: "error.cantGetToken".localized))
                }
            }
            return
        }

        let args: [String: Any] = [
            "UID": uid,
            "user_token": (userToken ?? "")
        ]
        postObjectCf(useCache: false, route: .walletUserCheck, args: args) { (result, error) in
            if let error = error {
                delegate(nil, error)
                return
            }

            if result.getInt("success") ?? 0 > 0 {
                let wallet = Wallet(dict: result)
                delegate(wallet, nil)
            } else {
                let msg = result.getString("msg") ?? result.getString("error") ?? ""
                delegate(nil, NetworkError.apiError(error: msg))
            }
        }
    }

    func loadUserInfo(force: Bool, delegate: @escaping (_ profile: Profile?, _ error: Error?) -> Void) {
        if !force,
           let profile = Profile.current {
            delegate(profile, nil)
            return
        }

        guard let uid = Auth.auth().currentUser?.uid else {
            delegate(nil, NetworkError.unauthenticated)
            return
        }

        guard let userToken = API.userTokens[uid] else {
            getUserToken { (token, error) in
                if token != nil && error == nil {
                    self.loadUserInfo(force: force, delegate: delegate)
                } else {
                    delegate(nil, error)
                }
            }
            return
        }

        let args = [
            "uid": uid,
            "user_token": userToken
        ]

        postObjectCf(useCache: false, route: .getProfileInformation, args: args) { (result, error) in
            if let error = error {
                delegate(nil, error)
                return
            }

            let success = result.getInt("success") ?? 0
            if success > 0 {
                let userDict = result["user"] as? [String: Any] ?? [:]
                let profile = Profile(dict: userDict)
                Profile.current = profile
                delegate(profile, nil)
            } else {
                delegate(nil, result.getApiError())
            }
        }
    }

    func updateUserInfo(profile: Profile, delegate: @escaping (_ error: Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            delegate(NetworkError.unauthenticated)
            return
        }

        var args = profile.toDict()
        args["uid"] = uid
        postObjectJs(useCache: false, route: .updateUser, args: args) { (result, error) in
            if let error = error {
                delegate(error)
                return
            }

            if let success = result.getInt("success"),
               success > 0 {
                delegate(nil)
            } else {
                delegate(result.getApiError())
            }
        }
    }

    func getLastMethodPayment(delegate: @escaping (_ paymentMethod: Card?, _ error: Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            delegate(nil, NetworkError.unauthenticated)
            return
        }

        postObjectCf(useCache: false, route: .lastMethodPayment,
                     args: ["UID": uid]) { (result, error) in
            if let error = error {
                delegate(nil, error)
                return
            }

            if let success = result.getInt("success"),
                success > 0 {
                if let result = result["results"] as? [String: Any] {
                    let card = Card(dict: result)
                    delegate(card, nil)
                } else {
                    delegate(nil, nil)
                }
            } else {
                delegate(nil, result.getApiError())
            }
        }
    }

    func getPaymentMethods(delegate: @escaping (_ paymentMethods: [Card], _ error: Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            delegate([], NetworkError.unauthenticated)
            return
        }

        let userToken = Profile.userToken ?? API.userTokens[uid]
        if userToken == nil {
            getUserStatus { _, token, error in
                if let error = error {
                    delegate([], error)
                } else if token != nil {
                    Profile.userToken = token
                    self.getPaymentMethods(delegate: delegate)
                } else {
                    delegate([], NetworkError.apiError(error: "error.cantGetToken".localized))
                }
            }
            return
        }

        postObjectCf(useCache: false,
                     route: .checkPaymentMethods,
                     args: [
                        "UID": uid,
                        "user_token": (userToken ?? "")
                     ]) { (result, error) in
            if let error = error {
                delegate([], error)
                return
            }

            if let success = result.getInt("success"),
                let results = result["results"] as? [Any],
                success > 0 {
                var cards = results
                    .compactMap {
                        $0 as? [String: Any]
                    }
                    .map {
                        Card(dict: $0)
                    }
                cards.insert(Card.apple, at: 0)
                cards.insert(Card.bitcoin, at: 1)
                cards.insert(Card.paypal, at: 2)
                delegate(cards, nil)
            } else {
                delegate([], result.getApiError())
            }
        }
    }

    func addCard(name: String, number: String, expMonth: String, expYear: String,
                 cvc: String, delegate: @escaping (_ error: Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            delegate(NetworkError.unauthenticated)
            return
        }

        let args: [String: Any] = [
            "UID": uid,
            "name": name,
            "number": number,
            "exp_month": expMonth,
            "exp_year": expYear,
            "cvc": cvc
        ]

        postObjectCf(useCache: false, route: .addCreditCard, args: args) { (result, error) in
            if let error = error {
                delegate(error)
                return
            }

            if let success = result.getInt("success"),
                success > 0 {
                delegate(nil)
            } else {
                if let errorMsg = result.getString("error") {
                    delegate(NetworkError.apiError(error: errorMsg))
                } else {
                    delegate(NetworkError.cardError)
                }
            }
        }
    }

    func getPurchaseHistory(delegate: @escaping (_ purchases: [Purchase], _ error: Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            delegate([], NetworkError.unauthenticated)
            return
        }

        if (Profile.userToken ?? API.userTokens[uid]) == nil {
            getUserStatus { _, token, error in
                if let error = error {
                    delegate([], error)
                } else if token != nil {
                    Profile.userToken = token
                    self.getPurchaseHistory(delegate: delegate)
                } else {
                    delegate([], NetworkError.apiError(error: "error.cantGetToken".localized))
                }
            }
            return
        }

        let args: [String: Any] = [
            "UID": uid,
            "user_token": Profile.userToken ?? API.userTokens[uid] ?? ""
        ]

        postObjectCf(useCache: false, route: .historicalSalesClient, args: args) { (result, error) in
            if let error = error {
                delegate([], error)
                return
            }

            if let success = result.getInt("success"),
               let results = result["results"] as? [Any],
                success > 0 {
                let purchases = results
                    .compactMap {
                        $0 as? [String: Any]
                    }
                    .map {
                        Purchase(dict: $0)
                    }
                    .sorted { (purchase0, purchase1) -> Bool in
                        (purchase0.date?.timeIntervalSince1970 ?? 0.0) > (purchase1.date?.timeIntervalSince1970 ?? 0.0)
                    }
                delegate(purchases, nil)
            } else {
                delegate([], result.getApiError())
            }
        }
    }

    func updateNotificationSettings(type: String, isEnabled: Bool,
                                    delegate: @escaping (_ error: Error?) -> Void = { _ in
        // Default empty delegate
    }) {
        guard let uid = Auth.auth().currentUser?.uid else {
            delegate(NetworkError.unauthenticated)
            return
        }

        let args: [String: Any] = [
            "isEnabled": isEnabled ? 1 : 0,
            "type": type,
            "uid": uid
        ]

        postObjectJs(useCache: false, route: .updateNotifications, args: args) { (result, error) in
            if let error = error {
                delegate(error)
                return
            }

            if let success = result.getInt("success"),
               success > 0 {
                delegate(nil)
            } else {
                delegate(result.getApiError())
            }
        }
    }

    func deleteCard(cusIdStripe: String, paymentMethod: String, delegate: @escaping (_ error: Error?) -> Void) {
        let args: [String: Any] = [
            "cus_id_stripe": cusIdStripe,
            "payment_method": paymentMethod
        ]

        postObjectCf(useCache: false, route: .deleteCreditCard, args: args) { (result, error) in
            if let error = error {
                delegate(error)
                return
            }

            if let success = result.getInt("success"),
               success > 0 {
                delegate(nil)
            } else {
                delegate(result.getApiError())
            }
        }
    }

    func getLocal(id: Int, place: Place?, delegate: @escaping (_ local: Local?, _ error: Error?) -> Void) {
        getObjectJs(useCache: false, route: .informationLocal,
                    args: ["id_local": id]) { (result, error) in
            if let error = error {
                delegate(nil, error)
            } else if let success = result.getInt("success"),
               let localDict = result["local"] as? [String: Any],
                success > 0 {
                let local = Local(place: place, dict: localDict)
                delegate(local, nil)
            } else {
                delegate(nil, result.getApiError())
            }
        }
    }

    func getInformationTransactionPurchase(
        piReference: String,
        delegate: @escaping (_ transactionInfo: TransactionInfo?, _ error: Error?) -> Void) {
        let args: [String: Any] = [
            "pi_reference": piReference
        ]

        postObjectCf(useCache: true, route: .informationTransactionPurchase,
                     args: args) { (result, error) in
            if let error = error {
                delegate(nil, error)
                return
            }

            if let success = result.getInt("success"),
               let result = result["result"] as? [String: Any],
               success > 0 {
                let transactionInfo = TransactionInfo(dict: result)
                delegate(transactionInfo, nil)
            } else {
                delegate(nil, result.getApiError())
            }
        }
    }

    fileprivate func processPayResult(
        _ error: Error?, _ result: [String: Any],
        _ delegate: @escaping (_ sale: Sale?, _ paymentIntent: PaymentIntent?, _ error: Error?) -> Void
    ) {
        if let error = error {
            delegate(nil, nil, error)
            return
        }

        if let success = result.getInt("success"),
           success > 0 {
            if success == 1,
               let saleDict = result["sale"] as? [String: Any] {
                let sale = Sale(dict: saleDict)
                var paymentIntent: PaymentIntent?
                if let paymentIntentDict = result["paymentIntent"] as? [String: Any] {
                    paymentIntent = PaymentIntent(dict: paymentIntentDict)
                }
                delegate(sale, paymentIntent, nil)
            } else if success == 2,
                      let result = result["paymentIntent"] as? [String: Any] {
                let paymentIntent = PaymentIntent(dict: result)
                delegate(nil, paymentIntent, nil)
            }
        } else {
            let errorMsg = result.getString("error") ?? result.getString("msg")
            if let dict = errorMsg?.asDict,
               let raw = dict["raw"] as? [String: Any] {
                delegate(nil, nil, NetworkError.paymentError(dict: raw))
            } else {
                delegate(nil, nil, result.getApiError())
            }
        }
    }

    func pay(_ arguments: PaymentArguments,
             delegate: @escaping (_ sale: Sale?, _ paymentIntent: PaymentIntent?, _ error: Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            delegate(nil, nil, NetworkError.unauthenticated)
            return
        }

        if (Profile.userToken ?? API.userTokens[uid]) == nil {
            getUserStatus { _, token, error in
                if let error = error {
                    delegate(nil, nil, error)
                } else if token != nil {
                    Profile.userToken = token
                    self.pay(arguments, delegate: delegate)
                } else {
                    delegate(nil, nil, NetworkError.apiError(error: "error.cantGetToken".localized))
                }
            }
            return
        }

        var args = arguments.argumentsDictionary
        args["uid"] = uid
        args["user_token"] = Profile.userToken ?? API.userTokens[uid] ?? ""

        // We pass action for CF-version of function
        args["action"] = "pay"

        postObjectCf(useCache: false, route: .buyTickets, args: args) { [weak self] (result, error) in
            self?.processPayResult(error, result, delegate)
        }
    }

    private func processCompletePaymentResult(
        _ error: Error?, _ result: [String: Any],
        _ delegate: @escaping (_ sale: Sale?, _ error: Error?) -> Void
    ) {
        if let error = error {
            delegate(nil, error)
            return
        }

        if let success = result.getInt("success"),
           success > 0 {
            if success == 1,
               let result = result["sale"] as? [String: Any] {
                let sale = Sale(dict: result)
                delegate(sale, nil)
            } else if success == 2,
                      let result = result["paymentIntent"] as? [String: Any],
                      let paymentIntent = PaymentIntent(dict: result) {
                if let reason = paymentIntent.reason,
                   NetworkError.declineCodes.contains(reason) {
                    delegate(nil, NetworkError.declineIntent(paymentIntent: paymentIntent))
                } else {
                    delegate(nil, NetworkError.apiError(error: "Payment error"))
                }
            }
        } else {
            let errorMsg = result.getString("error") ?? result.getString("msg")
            if let dict = errorMsg?.asDict,
               let raw = dict["raw"] as? [String: Any] {
                delegate(nil, NetworkError.paymentError(dict: raw))
            } else {
                delegate(nil, result.getApiError())
            }
        }
    }

    func completePayment(_ arguments: PaymentArguments, paymentIntent: String,
                         delegate: @escaping (_ sale: Sale?, _ error: Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            delegate(nil, NetworkError.unauthenticated)
            return
        }

        var args: [String: Any] = arguments.argumentsDictionary
        args["uid"] = uid
        args["payment_intent_id"] = paymentIntent

        // We pass action for CF-version of function
        args["action"] = "pay-complete"

        postObjectCf(useCache: false, route: .buyTickets, args: args) { [weak self] (result, error) in
            self?.processCompletePaymentResult(error, result, delegate)
        }
    }

    func getSaleByUpid(upid: String, delegate: @escaping (_ sale: Sale?, _ error: Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            delegate(nil, NetworkError.unauthenticated)
            return
        }

        var args = [
            "uid": uid,
            "upid": upid
        ]

        // We pass action for CF-version of function
        args["action"] = "pay-verifyUpid"

        postObjectCf(useCache: false, route: .buyTickets, args: args) { (result, error) in
            if let error = error {
                delegate(nil, error)
                return
            }

            if let success = result.getInt("success"),
                success > 0,
                let result = result["sale"] as? [String: Any] {
                let sale = Sale(dict: result)
                delegate(sale, nil)
            } else {
                delegate(nil, result.getApiError())
            }
        }
    }

    func getLET(sale: Sale?, delegate: @escaping (_ local: Local?, _ event: Event?, _ ticket: Ticket?, _ error: Error?) -> Void) {
        getLET(localId: sale?.localId, eventId: sale?.eventId, ticketId: sale?.ticketId, delegate: delegate)
    }

    func getLET(localId: Int?, eventId: Int?, ticketId: Int?,
                delegate: @escaping (_ local: Local?, _ event: Event?,
                                     _ ticket: Ticket?, _ error: Error?) -> Void) {
        var args: [String: Any] = [:]
        if let idLocal = localId {
            args["idLocal"] = idLocal
        }
        if let idEvent = eventId {
            args["idEvent"] = idEvent
        }
        if let idTicket = ticketId {
            args["idTicket"] = idTicket
        }

        postObjectCf(useCache: false, route: .getLET, args: args) { (result, error) in
            if let error = error {
                delegate(nil, nil, nil, error)
                return
            }

            let success = result.getInt("success") ?? 0
            if success > 0 {
                var local: Local?
                var event: Event?
                var ticket: Ticket?
                if let localDict = result["local"] as? [String: Any] {
                    local = Local(place: nil, dict: localDict)
                }
                if let eventDict = result["event"] as? [String: Any] {
                    event = Event(dict: eventDict)
                }
                if let ticketDict = result["ticket"] as? [String: Any] {
                    ticket = Ticket(dict: ticketDict)
                }
                delegate(local, event, ticket, nil)
            } else {
                delegate(nil, nil, nil, result.getApiError())
            }
        }
    }

    func getSaleByPiReference(piReference: String, delegate: @escaping (_ sale: Sale?, _ error: Error?) -> Void) {
        let args = [
            "piReference": piReference
        ]
        postObjectCf(useCache: true, route: .getSaleByPiReference,
                     args: args) { (result, error) in
            if let error = error {
                delegate(nil, error)
                return
            }

            let success = result.getInt("success") ?? 0
            if success > 0 {
                var sale: Sale?
                if let saleDict = result["sale"] as? [String: Any] {
                    sale = Sale(dict: saleDict)
                }
                delegate(sale, nil)
            } else {
                delegate(nil, result.getApiError())
            }
        }
    }

    func getEventInformation(eventId: Int,
                             delegate: @escaping (_ eventInfo: EventInfo?, _ eventRules: EventRules?,
                                                  _ tickets: [Ticket], _ error: Error?) -> Void) {
        let args = [
            "eventId": eventId
        ]
        getObjectJs(useCache: false, route: .eventInformation,
                    args: args) { (result, error) in
            if let error = error {
                delegate(nil, nil, [], error)
                return
            }

            let dictInfo = result["information"] as? [String: Any]
            let eventInfo = EventInfo(dict: dictInfo ?? [:])

            let dictRules = result["rules"] as? [String: Any]
            let eventRules = EventRules(dict: dictRules ?? [:])

            let arrTickets = result["tickets"] as? [Any]
            let tickets = (arrTickets ?? [])
                .compactMap { $0 as? [String: Any] }
                .map { Ticket(dict: $0) }

            delegate(eventInfo, eventRules, tickets, nil)
        }
    }

    func getEventInformationExtended(eventId: Int,
                                     delegate: @escaping (_ local: Local?, _ event: Event?,
                                                          _ eventInfo: EventInfo?, _ eventRules: EventRules?,
                                                          _ tickets: [Ticket], _ error: Error?) -> Void) {
        let args = [
            "eventId": eventId,
            "extended": 1
        ]
        getObjectJs(useCache: false, route: .eventInformation, args: args) { (result, error) in
            if let error = error {
                delegate(nil, nil, nil, nil, [], error)
                return
            }

            let place: Place?
            if let dictPlace = result["place"] as? [String: Any] {
                place = Place(dict: dictPlace)
            } else {
                place = nil
            }

            let local: Local?
            if let dictLocal = result["local"] as? [String: Any] {
                local = Local(place: place, dict: dictLocal)
            } else {
                local = nil
            }

            let event: Event?
            if let dictEvent = result["event"] as? [String: Any] {
                event = Event(dict: dictEvent)
            } else {
                event = nil
            }

            let dictInfo = result["information"] as? [String: Any]
            let eventInfo = EventInfo(dict: dictInfo ?? [:])

            let dictRules = result["rules"] as? [String: Any]
            let eventRules = EventRules(dict: dictRules ?? [:])

            let arrTickets = result["tickets"] as? [Any]
            let tickets = (arrTickets ?? [])
                .compactMap { $0 as? [String: Any] }
                .map { Ticket(dict: $0) }

            delegate(local, event, eventInfo, eventRules, tickets, nil)
        }
    }

    func changeUsername(username: String, delegate: @escaping (_ error: Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            delegate(NetworkError.unauthenticated)
            return
        }

        let args = [
            "UID": uid,
            "username": username
        ]

        postObjectCf(useCache: false, route: .changeUsername, args: args) { (result, error) in
            if let error = error {
                delegate(error)
                return
            }

            let errorMsg = result.getString("msg") ?? "Unknown server error"
            let errorMsgLc = errorMsg.lowercased()
            if errorMsgLc.contains("username") && errorMsgLc.contains("changed") {
                delegate(nil)
            } else if errorMsgLc.contains("username") && errorMsgLc.contains("not") && errorMsgLc.contains("available") {
                delegate(NetworkError.apiError(error: "error.usernameIsBusy".localized))
            } else {
                delegate(NetworkError.apiError(error: errorMsg))
            }
        }
    }

    func saveTokenDevice(delegate: ((_ error: Error?) -> Void)? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else {
            delegate?(NetworkError.unauthenticated)
            return
        }

        guard let token = OneSignal.getPermissionSubscriptionState()?.subscriptionStatus?.userId else {
            delegate?(NetworkError.noToken)
            return
        }

        let args = [
            "UID": uid,
            "token_device": token
        ]

        postObjectCf(useCache: false, route: .saveTokenDevice, args: args) { (_, error) in
            delegate?(error)
        }
    }

    func getUserStatus(delegate: @escaping (_ status: String?, _ token: String?, _ error: Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            delegate(nil, nil, NetworkError.unauthenticated)
            return
        }

        postObjectJs(useCache: false, route: .userStatus,
                     args: ["uid": uid]) { (result, error) in
            if let error = error {
                delegate(nil, nil, error)
            } else if result.getInt("success") == 1 {
                Profile.userToken = result.getString("token")
                delegate(result.getString("status"), result.getString("token"), nil)
            } else {
                delegate(nil, nil, NetworkError.apiError(error: result.getString("error") ??
                                                         "error.checkError".localized))
            }
        }
    }

    func getEventStatus(eventId: Int, delegate: @escaping (_ status: String?, _ error: Error?) -> Void) {
        postObjectJs(useCache: false, route: .eventStatus,
                     args: ["eventId": eventId]) { (result, error) in
            if let error = error {
                delegate(nil, error)
            } else if result.getInt("success") == 1 {
                delegate(result.getString("status"), nil)
            } else {
                delegate(nil, NetworkError.apiError(error: result.getString("error") ??
                                                    "error.checkError".localized))
            }
        }
    }

    func getUserRange(delegate: @escaping (_ status: String?, _ error: Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            delegate(nil, NetworkError.unauthenticated)
            return
        }

        postObjectCf(useCache: false, route: .checkRangeUser, args: ["uid": uid]) { (result, error) in
            if let error = error {
                delegate(nil, error)
            } else if result.getInt("success") == 1 {
                delegate(result.getString("range"), nil)
            } else {
                delegate(nil, NetworkError.apiError(error: result.getString("error") ??
                                                    "error.checkError".localized))
            }
        }
    }

    func userCanUploadPhotos(delegate: @escaping (_ canUploadPhotos: Bool, _ error: Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            delegate(false, NetworkError.unauthenticated)
            return
        }

        postObjectJs(useCache: false, route: .userCanUploadPhotos,
                     args: ["uid": uid]) { (result, error) in
            if let error = error {
                delegate(false, error)
            } else if result.getInt("success") == 1 {
                delegate(result.getInt("canUploadPhotos") ?? 0 > 0, nil)
            } else {
                delegate(false, NetworkError.apiError(error: result.getString("error") ??
                                                      "error.checkError".localized))
            }
        }
    }

    func addInterestLocal(localId: Int) {
        let args: [String: Any] = [
            "id_local": localId
        ]

        postObjectCf(useCache: false, route: .addInterestLocal, args: args) { (_, _) in
            // We don't need to handle response
        }
    }

    func getUserTickets(delegate: @escaping (_ tickets: [HistoryTicket], _ error: Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            delegate([], NetworkError.unauthenticated)
            return
        }

        let userToken = Profile.userToken ?? API.userTokens[uid]
        if userToken == nil {
            getUserStatus { _, token, error in
                if let error = error {
                    delegate([], error)
                } else if token != nil {
                    Profile.userToken = token
                    self.getUserTickets(delegate: delegate)
                } else {
                    delegate([], NetworkError.apiError(error: "error.cantGetToken".localized))
                }
            }
            return
        }

        let args: [String: Any] = [
            "UID": uid,
            "user_token": (userToken ?? "")
        ]

        postObjectCf(useCache: false, route: .checkTicketsClient, args: args) { (result, error) in
            if let error = error {
                delegate([], error)
                return
            }

            if let success = result.getInt("success"),
               let results = result["results"] as? [Any],
                success > 0 {
                let tickets = results
                    .compactMap { $0 as? [String: Any] }
                    .map { HistoryTicket(dict: $0) }
                delegate(tickets, nil)
            } else {
                delegate([], result.getApiError())
            }
        }
    }

    func checkInformationTicket(piReference: String, delegate: @escaping (_ saleInfo: SaleInfo?, _ error: Error?) -> Void) {
        let args: [String: Any] = [
            "pi_reference": piReference
        ]

        postObjectCf(useCache: false, route: .checkInformationTicket, args: args) { (result, error) in
            if let error = error {
                delegate(nil, error)
                return
            }

            if let success = result.getInt("success"),
               let results = result["results"] as? [Any],
                success > 0 {
                let tickets = results
                    .compactMap { $0 as? [String: Any] }
                    .map { SaleInfo(dict: $0) }
                delegate(tickets.first, nil)
            } else {
                delegate(nil, result.getApiError())
            }
        }
    }

    func saveShoppingCart(eventId: Int) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        let args: [String: Any] = [
            "UID": uid,
            "event_id": eventId
        ]

        postObjectCf(useCache: false, route: .shoppingCartSave, args: args) { (_, _) in
            // We don't need to handle response
        }
    }

    func checkPromocode(promocode: String, localId: Int, eventId: Int, ticketId: Int,
                        delegate: @escaping (_ promocode: Promocode?, _ error: Error?) -> Void) {
        let args: [String: Any] = [
            "promocode": promocode,
            "id_local": localId,
            "id_event": eventId,
            "id_ticket": ticketId
        ]

        postObjectCf(useCache: false, route: .checkPromocode, args: args) { (result, error) in
            if let error = error {
                delegate(nil, error)
                return
            }

            if let success = result.getInt("success"),
               let results = result["results"] as? [Any],
                success > 0 {
                let tickets = results
                    .compactMap { $0 as? [String: Any] }
                    .map { Promocode(dict: $0) }
                delegate(tickets.first, nil)
            } else {
                delegate(nil, result.getApiError())
            }
        }
    }

    func checkPromocodeUsed(promocode: String, delegate: @escaping (_ used: Bool?, _ error: Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        let args = [
            "promocode": promocode,
            "uid": uid
        ]

        postObjectJs(useCache: false, route: .checkIfPromocodeUsed,
                     args: args) { (result, error) in
            if let error = error {
                delegate(nil, error)
                return
            }

            if let success = result.getInt("success"),
                let used = result.getInt("used"),
                success > 0 {
                delegate(used > 0, nil)
            } else {
                delegate(nil, result.getApiError())
            }
        }
    }

    func uploadPhotoLocal(localId: Int, image: UIImage, delegate: @escaping (_ urls: [String], _ error: Error?) -> Void) {

        let imageOptimized = image.resized(maxWidth: 640, maxHeight: 800)!
        let imageData = imageOptimized.jpegData(compressionQuality: 0.8)!

        let thumb = image.square()!.resized(maxSize: 293)!
        let thumbData = thumb.jpegData(compressionQuality: 0.6)!

        var args: [String: Any] = [
            "local_id": localId,
            "full": imageData,
            "thumb": thumbData
        ]

        if let uid = Auth.auth().currentUser?.uid {
            args["UID"] = uid
        }

        uploadObjectCf(route: .photoLocal, args: args) { (result, error) in
            if let error = error {
                delegate([], error)
                return
            }

            if let success = result.getInt("success"),
               let urls = result["urls"] as? [String],
                success > 0 {
                delegate(urls, nil)
            } else {
                delegate([], result.getApiError())
            }
        }
    }

    func uploadPhotoLocalContribution(localId: Int, image: UIImage, delegate: @escaping (_ urls: [String], _ error: Error?) -> Void) {
        let imageOptimized = image.resized(maxSize: 1024)!
        let imageData = imageOptimized.jpegData(compressionQuality: 0.8)!

        var args: [String: Any] = [
            "local_id": localId,
            "full": imageData
        ]

        if let uid = Auth.auth().currentUser?.uid {
            args["UID"] = uid
        }

        uploadObjectCf(route: .photoLocalContribution, args: args) { (result, error) in
            if let error = error {
                delegate([], error)
                return
            }

            if let success = result.getInt("success"),
               let urls = result["urls"] as? [String],
                success > 0 {
                delegate(urls, nil)
            } else {
                delegate([], result.getApiError())
            }
        }
    }

    func getSalesResume(eventId: Int, delegate: @escaping (_ sales: [EventSaleSummary], _ error: Error?) -> Void) {
        let args: [String: Any] = [
            "id_event": eventId
        ]

        postObjectCf(useCache: false, route: .resumSalesQR, args: args) { (result, error) in
            if let error = error {
                delegate([], error)
                return
            }

            if let success = result.getInt("success"),
               let results = result["results"] as? [Any],
                success > 0 {
                let sales = results
                    .compactMap { $0 as? [String: Any] }
                    .map { EventSaleSummary(dict: $0) }
                delegate(sales, nil)
            } else {
                delegate([], result.getApiError())
            }
        }
    }

    func getQRTicketsForEvent(eventId: Int, delegate: @escaping (_ tickets: [QRSale], _ error: Error?) -> Void) {
        let args: [String: Any] = [
            "id_event": eventId
        ]

        postObjectCf(useCache: false, route: .showQRTicketsEvent, args: args) { (result, error) in
            if let error = error {
                delegate([], error)
                return
            }

            if let success = result.getInt("success"),
               let results = result["results"] as? [Any],
                success > 0 {
                let tickets = results
                    .compactMap { $0 as? [String: Any] }
                    .map { QRSale(dict: $0) }
                delegate(tickets, nil)
            } else {
                delegate([], result.getApiError())
            }
        }
    }

    func getAmountPurchasingTicket(eventId: Int, delegate: @escaping (_ amount: Int?, _ error: Error?) -> Void) {
        let args: [String: Any] = [
            "id_event": eventId
        ]

        postObjectCf(useCache: false, route: .countClientsInterestingPurchase,
                     args: args) { (result, error) in
            if let error = error {
                delegate(nil, error)
                return
            }

            if let success = result.getInt("success"),
                let msg = result["msg"] as? [String: Any],
                success > 0 {
                delegate(msg.getInt("count"), nil)
            } else {
                delegate(nil, result.getApiError())
            }
        }
    }

    func checkQRInformation(qrCode: String, idEvent: Int, delegate: @escaping (_ info: QRInfo?, _ error: Error?) -> Void) {
        let args: [String: Any] = [
            "QR_code": qrCode,
            "id_event": idEvent
        ]

        postObjectCf(useCache: false, route: .checkQRInformation, args: args) { (result, error) in
            if let error = error {
                delegate(nil, error)
                return
            }

            if let success = result.getInt("success"),
                let results = result["results"] as? [Any],
                success > 0 {
                let qrInfos = results
                    .compactMap { $0 as? [String: Any] }
                    .map { QRInfo(dict: $0) }
                delegate(qrInfos.first, nil)
            } else if result.getInt("success") == nil {
                let qrInfo = QRInfo(dict: result)
                delegate(qrInfo, nil)
            } else {
                delegate(nil, result.getApiError())
            }
        }
    }

    func commentTicketScanner(qrCode: String, comment: String, delegate: @escaping (_ error: Error?) -> Void) {
        let args: [String: Any] = [
            "QR_code": qrCode,
            "comment_ticket": comment
        ]

        postObjectCf(useCache: false, route: .commentTicketScanner, args: args) { (_, error) in
            delegate(error)
        }
    }

    func changeRangeToStaff(delegate: @escaping (_ error: Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            delegate(NetworkError.unauthenticated)
            return
        }

        postObjectCf(useCache: false, route: .changeRangeToStaff, args: ["UID": uid]) { (_, error) in
            delegate(error)
        }
    }

    func checkDocumentsStaff(delegate: @escaping (_ documents: [StaffDocument], _ error: Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            delegate([], NetworkError.unauthenticated)
            return
        }

        postObjectCf(useCache: false, route: .checkDocumentsStaff, args: ["UID": uid]) { (result, error) in
            if let error = error {
                delegate([], error)
                return
            }

            if let success = result.getInt("success"),
                let results = result["documents"] as? [Any],
                success > 0 {
                let docs = results
                    .compactMap { $0 as? [String: Any] }
                    .map { StaffDocument(dict: $0) }
                delegate(docs, nil)
            } else {
                delegate([], result.getApiError())
            }
        }
    }

    func deletePhotoLocal(idLocal: Int, urlFull: String, delegate: @escaping (_ error: Error?) -> Void) {
        let args: [String: Any] = [
            "id_local": idLocal,
            "URL_full": urlFull
        ]

        postObjectCf(useCache: false, route: .deletePhotoLocal, args: args) { (result, error) in
            if let error = error {
                delegate(error)
                return
            }

            if let success = result.getInt("success"),
                success > 0 {
                delegate(nil)
            } else {
                let errorMsg = result.getString("msg") ?? "Unknown server error"
                delegate(NetworkError.apiError(error: errorMsg))
            }
        }
    }

    func generateDocument(_ arguments: GenerateDocumentsArguments,
                          delegate: @escaping (_ documents: [StaffDocument], _ error: Error?) -> Void) {
        postObjectCf(useCache: false, route: .contractGenerator, args: arguments.argumentsDictionary) { (result, error) in
            if let error = error {
                delegate([], error)
                return
            }

            if let success = result.getInt("success"),
                let results = result["documents"] as? [Any],
                success > 0 {
                let docs = results
                    .compactMap { $0 as? [String: Any] }
                    .map { StaffDocument(dict: $0) }
                delegate(docs, nil)
            } else {
                delegate([], result.getApiError())
            }
        }
    }

    func signContract(documentId: Int, signature: UIImage, delegate: @escaping (_ documents: [StaffDocument], _ error: Error?) -> Void) {
        let imageOptimized = signature.resized(maxSize: 300)!
        let imageData = imageOptimized.jpegData(compressionQuality: 0.8)!

        getIpInfo { (ipInfo, error) in
            if let error = error {
                delegate([], error)
                return
            }

            let ip = ipInfo?.ip ?? API.defaultIp

            let args: [String: Any] = [
                "id_document": documentId,
                "ip": ip,
                "image_draw": imageData,
                "device": UIDevice.modelName
            ]

            self.uploadObjectCf(route: .contractSignatureCreator, args: args) { (result, error) in
                if let error = error {
                    delegate([], error)
                    return
                }

                if let success = result.getInt("success"),
                    let results = result["documents"] as? [Any],
                    success > 0 {
                    let docs = results
                        .compactMap { $0 as? [String: Any] }
                        .map { StaffDocument(dict: $0) }
                    delegate(docs, nil)
                } else {
                    delegate([], result.getApiError())
                }
            }
        }
    }

    func checkBankStaff(delegate: @escaping (_ bankAccounts: [StaffBankAccount], _ error: Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            delegate([], NetworkError.unauthenticated)
            return
        }

        postObjectCf(useCache: false, route: .checkBankStaff,
                     args: ["UID": uid]) { (result, error) in
            if let error = error {
                delegate([], error)
                return
            }

            if let success = result.getInt("success"),
                success > 0 {
                let results = result["accounts"] as? [Any] ?? []
                let accts = results
                    .compactMap { $0 as? [String: Any] }
                    .map { StaffBankAccount(dict: $0) }
                delegate(accts, nil)
            } else {
                delegate([], result.getApiError())
            }
        }
    }

    private func checkQRInformation(args: [String: Any], delegate: @escaping (_ qrInfo: QRInfo?, _ error: Error?) -> Void) {
        postObjectCf(useCache: false, route: .checkQRInformation, args: args) { (result, error) in
            if let error = error {
                delegate(nil, error)
                return
            }

            if let success = result.getInt("success"),
               success > 0 {
                let results = result["results"] as? [Any] ?? []
                let qrInfos = results
                    .compactMap { $0 as? [String: Any] }
                    .map { QRInfo(dict: $0) }
                delegate(qrInfos.first, nil)
            } else if result.getInt("success") == nil {
                let qrInfo = QRInfo(dict: result)
                delegate(qrInfo, nil)
            } else {
                delegate(nil, result.getApiError())
            }
        }
    }

    func validateQRCode(qrCode: String, idEvent: Int, delegate: @escaping (_ qrInfo: QRInfo?, _ error: Error?) -> Void) {
        let args: [String: Any] = [
            "QR_code": qrCode,
            "id_event": idEvent,
            "action": "validate"
        ]

        self.checkQRInformation(args: args, delegate: delegate)
    }

    func checkHowManyTicketsYouCanReject(qrCode: String, delegate: @escaping (_ ticketsToReject: Int?, _ error: Error?) -> Void) {
        let args: [String: Any] = [
            "QR_code": qrCode
        ]

        postObjectCf(useCache: false, route: .checkHowManyYouCanReject, args: args) { (result, error) in
            if let error = error {
                delegate(nil, error)
                return
            }

            if let success = result.getInt("success"),
                success > 0 {
                let ticketsToReject = result.getInt("tickets_to_reject")
                delegate(ticketsToReject, nil)
            } else {
                delegate(nil, result.getApiError())
            }
        }
    }

    func rejectQRCode(qrCode: String, idEvent: Int, numberToReject: Int, delegate: @escaping (_ qrInfo: QRInfo?, _ error: Error?) -> Void) {
        let args: [String: Any] = [
            "QR_code": qrCode,
            "id_event": idEvent,
            "action": "reject",
            "number_to_reject": numberToReject
        ]

        self.checkQRInformation(args: args, delegate: delegate)
    }

    private func getDataFromArgument(_ argument: Any) -> Any {
        if let data = argument as? Data {
            return data
        } else if let image = argument as? UIImage {
            return image.resized(maxSize: 1024)!.jpegData(compressionQuality: 0.8)!
        } else if let frontalURL = argument as? URL,
                  let data = try? Data(contentsOf: frontalURL) {
            return data
        } else if let string = argument as? String,
                  let dataUrl = URL(string: string),
                  let data = try? Data(contentsOf: dataUrl) {
            return data
        } else {
            return argument
        }
    }

    func uploadDNIStaff(frontal: Any, trasero: Any, delegate: @escaping (_ error: Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            delegate(NetworkError.unauthenticated)
            return
        }

        getIpInfo { (ipInfo, error) in
            if let error = error {
                delegate(error)
                return
            }

            let ip = ipInfo?.ip ?? API.defaultIp

            let args: [String: Any] = [
                "UID": uid,
                "ip": ip,
                "frontal": self.getDataFromArgument(frontal),
                "trasero": self.getDataFromArgument(trasero)
            ]

            self.uploadObjectCf(route: .uploadDNIStaff, args: args) { (result, error) in
                if let error = error {
                    delegate(error)
                } else if let success = result.getInt("success"),
                    success > 0 {
                    delegate(nil)
                } else {
                    delegate(result.getApiError())
                }
            }
        }
    }

    func getLocalsForStaff(delegate: @escaping (_ locals: [Local], _ error: Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            delegate([], NetworkError.unauthenticated)
            return
        }

        postObjectCf(useCache: false, route: .checkLocalsStaff, args: ["UID": uid]) { (result, error) in
            if let error = error {
                delegate([], error)
                return
            }

            if let success = result.getInt("success"),
                let results = result["locals"] as? [Any],
                success > 0 {
                let locals: [Local] = results
                    .compactMap {
                        $0 as? [String: Any]
                    }
                    .map {
                        let place = Place(dict: $0)
                        return Local(place: place, dict: $0)
                    }
                delegate(locals, nil)
            } else {
                delegate([], result.getApiError())
            }
        }
    }

    func getReaderKey(idLocal: Int, delegate: @escaping (_ key: String?, _ error: Error?) -> Void) {
        let auth = [
            "id_local": idLocal
        ]

        postObjectCf(useCache: false, route: .getReaderKey, args: auth) { (result, error) in
            if let error = error {
                delegate(nil, error)
                return
            }

            if let success = result.getInt("success"),
                success > 0 {
                let licenseKey = result.getString("key")
                delegate(licenseKey, nil)
            } else {
                delegate(nil, result.getApiError())
            }
        }
    }

    func uploadBankDocument(
        titular: String, ibanNumber: String, data: Data,
        delegate: @escaping (_ document: StaffBankAccount?, _ error: Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            delegate(nil, NetworkError.unauthenticated)
            return
        }

        getIpInfo { (ipInfo, error) in
            if let error = error {
                delegate(nil, error)
                return
            }

            let ip = ipInfo?.ip ?? API.defaultIp

            let args: [String: Any] = [
                "type_document": "bank",
                "UID": uid,
                "titular": titular,
                "IBAN": ibanNumber,
                "ip": ip,
                "document_file": data
            ]

            self.uploadObjectCf(route: .documentUploader, args: args) { (result, error) in
                if let error = error {
                    delegate(nil, error)
                    return
                }

                if let success = result.getInt("success"),
                    success > 0 {
                    if let bankJson = result["bank"] as? [String: Any] {
                        let bank = StaffBankAccount(dict: bankJson)
                        delegate(bank, nil)
                    } else {
                        delegate(nil, nil)
                    }
                } else {
                    delegate(nil, result.getApiError())
                }
            }
        }
    }

    func uploadDocument(documentId: Int, data: Data, delegate: @escaping (_ document: StaffDocument?, _ error: Error?) -> Void) {
        getIpInfo { (ipInfo, error) in
            if let error = error {
                delegate(nil, error)
                return
            }

            let ip = ipInfo?.ip ?? API.defaultIp

            let args: [String: Any] = [
                "id_file": documentId,
                "ip": ip,
                "document_file": data
            ]

            self.uploadObjectCf(route: .documentUploader, args: args) { (result, error) in
                if let error = error {
                    delegate(nil, error)
                    return
                }

                if let success = result.getInt("success"),
                    success > 0 {
                    if let documentJson = result["document"] as? [String: Any] {
                        let document = StaffDocument(dict: documentJson)
                        delegate(document, nil)
                    } else {
                        delegate(nil, nil)
                    }
                } else {
                    delegate(nil, result.getApiError())
                }
            }
        }
    }

    func createNewLocal(_ arguments: NewLocalArguments,
                        delegate: @escaping (_ place: Place?, _ local: Local?, _ error: Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            delegate(nil, nil, NetworkError.unauthenticated)
            return
        }

        var args: [String: Any] = arguments.argumentsDictionary
        args["UID"] = uid

        postObjectCf(useCache: false, route: .createNewLocal, args: args) { (result, error) in
            if let error = error {
                delegate(nil, nil, error)
                return
            }

            if let success = result.getInt("success"),
                success > 0 {
                if let localJson = result["local"] as? [String: Any] {
                    let place = Place(dict: localJson)
                    let local = Local(place: place, dict: localJson)
                    delegate(place, local, nil)
                } else {
                    delegate(nil, nil, nil)
                }
            } else {
                delegate(nil, nil, result.getApiError())
            }
        }
    }

    func checkCountriesColaboration(delegate: @escaping (_ countries: [StaffCountry], _ error: Error?) -> Void) {
        postObjectCf(useCache: true, route: .checkCountriesColaboration, args: [:]) { (result, error) in
            if let error = error {
                delegate([], error)
                return
            }

            if let success = result.getInt("success"),
                success > 0 {
                if let results = result["result"] as? [Any] {
                    let countries = results
                        .compactMap { $0 as? [String: Any] }
                        .compactMap { StaffCountry(dict: $0) }
                    delegate(countries, nil)
                } else {
                    delegate([], nil)
                }
            } else {
                delegate([], result.getApiError())
            }
        }
    }

    func createDocumentationStaff(country: String, type: String, delegate: @escaping (_ documents: [StaffDocument], _ error: Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            delegate([], NetworkError.unauthenticated)
            return
        }

        let args: [String: Any] = [
            "UID": uid,
            "country": country,
            "professional_type": type
        ]

        postObjectCf(useCache: false, route: .createDocumentationStaff,
                     args: args) { (result, error) in
            if let error = error {
                delegate([], error)
                return
            }

            if let success = result.getInt("success"),
                success > 0 {
                if let results = result["documents"] as? [Any] {
                    let docs = results
                        .compactMap { $0 as? [String: Any] }
                        .map { StaffDocument(dict: $0) }
                    delegate(docs, nil)
                } else {
                    delegate([], nil)
                }
            } else {
                delegate([], result.getApiError())
            }
        }
    }

    func checkIfCanSellTickets(delegate: @escaping (_ result: Bool, _ error: Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            delegate(false, NetworkError.unauthenticated)
            return
        }

        let args: [String: Any] = [
            "UID": uid
        ]

        postObjectCf(useCache: false, route: .checkIfCanSell, args: args) { (result, error) in
            if let error = error {
                delegate(false, error)
                return
            }

            if let success = result.getInt("success"),
                success > 0 {
                if let result = result.getString("result") {
                    delegate(result == "ready_to_sell_tickets", nil)
                } else {
                    delegate(false, nil)
                }
            } else {
                delegate(false, result.getApiError())
            }
        }
    }

    func sendInvoiceCopyByEmail(
        piReference: String,
        delegate: @escaping (_ error: Error?) -> Void = { _ in
            // Default empty delegate
        }) {
        let args: [String: Any] = [
            "pi_reference": piReference
        ]

        postObjectCf(useCache: false, route: .sendCopyEmail, args: args) { (result, error) in
            if let error = error {
                delegate(error)
                return
            }

            if let success = result.getInt("success"),
                success > 0 {
                delegate(nil)
            } else {
                delegate(result.getApiError())
            }
        }
    }

    func getEmployeeList(delegate: @escaping (_ employees: [Employee], _ error: Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            delegate([], NetworkError.unauthenticated)
            return
        }

        let args: [String: Any] = [
            "UID": uid
        ]

        postObjectCf(useCache: false, route: .checkEmployeesList, args: args) { (result, error) in
            if let error = error {
                delegate([], error)
                return
            }

            if let success = result.getInt("success"),
                success > 0 {
                let employeesArr = result["employees"] as? [Any] ?? []
                let employees = employeesArr
                    .compactMap { $0 as? [String: Any] }
                    .map { Employee(dict: $0) }
                delegate(employees, nil)
            } else {
                delegate([], result.getApiError())
            }
        }
    }

    func uploadLocalImage(data: Data, idLocal: Int, type: String, delegate: @escaping (_ error: Error?) -> Void) {
        let args: [String: Any] = [
            "file": data,
            "$idLocal": idLocal,
            "$type": type
        ]

        let mimeType: String
        if type == "avatar" {
            mimeType = "image/png"
        } else if type == "thumb" {
            mimeType = "image/jpeg"
        } else {
            delegate(NetworkError.apiError(error: "Incorrect image type - \(type)"))
            return
        }

        uploadObjectJs(route: .uploadLocalImage, args: args, mimeType: mimeType) { (result, error) in
            if let error = error {
                delegate(error)
                return
            }

            if let success = result.getInt("success"),
                success > 0 {
                delegate(nil)
            } else {
                delegate(result.getApiError())
            }
        }
    }

    func checkMicroblinkSerial(delegate: @escaping (_ serial: String?, _ error: Error?) -> Void) {
        postObjectCf(useCache: false, route: .checkMicroblinkSerial,
                     args: [:]) { (result, error) in
            if let error = error {
                delegate(nil, error)
                return
            }

            if let success = result.getInt("success"),
               let serials = result["result"] as? [String: Any],
                success > 0 {
                let licenseKey = serials.getString("microblink_ios")
                delegate(licenseKey, nil)
            } else {
                delegate(nil, result.getApiError())
            }
        }
    }

    func checkMobileVerification(delegate: @escaping (_ verificationStatus: String?, _ error: Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            delegate(nil, NetworkError.unauthenticated)
            return
        }

        let args: [String: Any] = [
            "UID": uid
        ]

        postObjectCf(useCache: false, route: .checkMobileVerification, args: args) { (result, error) in
            if let error = error {
                delegate(nil, error)
                return
            }

            if let success = result.getInt("success"),
               let smsVerification = result.getString("sms_verification"),
               success > 0 {
                delegate(smsVerification, nil)
            } else {
                delegate(nil, result.getApiError())
            }
        }
    }

    func sendSMSVerification(mobilePhone: String, delegate: @escaping (_ error: Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            delegate(NetworkError.unauthenticated)
            return
        }

        getUserToken { userToken, error in
            if let error = error {
                delegate(error)
                return
            }

            let args: [String: Any] = [
                "UID": uid,
                "mobile_phone": mobilePhone,
                "user_token": (userToken ?? "")
            ]

            self.postObjectCf(useCache: false, route: .sendSMSVerification, args: args) { (result, error) in
                if let error = error {
                    delegate(error)
                    return
                }

                if let success = result.getInt("success"),
                   success > 0 {
                    delegate(nil)
                } else {
                    delegate(result.getApiError())
                }
            }
        }
    }

    func checkSMS(mobilePhone: String, code: String, delegate: @escaping (_ validated: Bool, _ error: Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            delegate(false, NetworkError.unauthenticated)
            return
        }

        getUserToken { userToken, error in
            if let error = error {
                delegate(false, error)
                return
            }

            let args: [String: Any] = [
                "UID": uid,
                "mobile_phone": mobilePhone,
                "code": code,
                "user_token": (userToken ?? "")
            ]

            self.postObjectCf(useCache: false, route: .checkSMS, args: args) { (result, error) in
                if let error = error {
                    delegate(false, error)
                    return
                }

                if let success = result.getInt("success"),
                   success > 0 {
                    let msg = result.getString("msg")?.lowercased()
                    delegate(msg == "verified", nil)
                } else {
                    delegate(false, result.getApiError())
                }
            }
        }
    }

    func checkReferredUrl(delegate: @escaping (_ url: String?, _ error: Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            delegate(nil, NetworkError.unauthenticated)
            return
        }

        let args: [String: Any] = [
            "UID": uid
        ]

        postObjectCf(useCache: false, route: .checkReferredURL, args: args) { (result, error) in
            if let error = error {
                delegate(nil, error)
                return
            }

            if let success = result.getInt("success"),
               success > 0 {
                let url = result.getString("reffered_URL")
                delegate(url, nil)
            } else {
                delegate(nil, result.getApiError())
            }
        }
    }

    func checkReferal(delegate: @escaping (_ refCode: String?, _ amount: [String: Int], _ error: Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            delegate(nil, [:], NetworkError.unauthenticated)
            return
        }

        if let token = Profile.userToken ?? API.userTokens[uid] {
            let args: [String: Any] = [
                "uid": uid,
                "user_token": token
            ]

            postObjectCf(useCache: false, route: .checkReferal, args: args) { (result, error) in
                if let error = error {
                    delegate(nil, [:], error)
                    return
                }

                let refCode = result.getString("ref_code")
                let arrAmount = result["amount"] as? [Any]
                var amount: [String: Int] = [:]
                arrAmount?.forEach {
                    if let dict = $0 as? [String: Any],
                       let currency = dict.getString("currency"),
                       let quantity = dict.getInt("quantity") {
                        amount[currency] = quantity
                    }
                }

                delegate(refCode, amount, nil)
            }
        } else {
            getUserStatus { _, token, error in
                if let error = error {
                    delegate(nil, [:], error)
                } else if token != nil {
                    Profile.userToken = token
                    self.checkReferal(delegate: delegate)
                } else {
                    delegate(nil, [:], NetworkError.apiError(error: "Can't get token. Try to log out and log in again"))
                }
            }
        }

    }

    static var userTokens: [String: String] = [:]
    private static let defaultIp = "0.0.0.0"
}
