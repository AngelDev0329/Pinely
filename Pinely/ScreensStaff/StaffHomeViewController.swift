//
//  StaffHomeViewController.swift
//  Pinely
//

import UIKit
import SwiftEventBus
import Microblink

class StaffHomeViewController: ViewController {
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var swiSales: SwiftySwitch!
    @IBOutlet weak var swiDailyResum: SwiftySwitch!
    @IBOutlet weak var swiPaymentNotifications: SwiftySwitch!

    @IBOutlet weak var tvDocs: UITableView!
    @IBOutlet weak var lcDocsHeight: NSLayoutConstraint!

    @IBOutlet weak var aiLoading: UIActivityIndicatorView!
    @IBOutlet weak var aiBankAccount: UIActivityIndicatorView!

    @IBOutlet weak var vFinishRegistration: UIView!
    @IBOutlet weak var vBankAccountStatus: UIView!

    var docs: [StaffDocument] = []
    var accounts: [StaffBankAccount] = []
    var staffNotEnterCountry = false
    var documentsAreLoading = false

    override func viewDidLoad() {
        super.viewDidLoad()

        swiSales.delegate = self
        swiDailyResum.delegate = self
        swiPaymentNotifications.delegate = self

        loadDocuments()
        loadNotifications()
        loadBankAccount()

        SwiftEventBus.onMainThread(self, name: "documentsChanged") { (_) in
            self.loadDocuments()
        }
    }

    deinit {
        SwiftEventBus.unregister(self)
    }

    private func loadBankAccount() {
        API.shared.checkBankStaff { (accounts, _) in
            self.accounts = accounts
            self.aiBankAccount.stopAnimating()
            if accounts.count > 0 && accounts[0].status != "rejected" {
                if accounts[0].status == "waiting-review" {
                    // Waiting for review. Yellow
                    self.vBankAccountStatus.backgroundColor = UIColor(hex: 0xFFD800)!
                } else if accounts[0].status == "approved" {
                    // Approved account. Green
                    self.vBankAccountStatus.backgroundColor = UIColor(hex: 0x03E218)!
                } else {
                    // Unknown. Gray
                    self.vBankAccountStatus.backgroundColor = UIColor(hex: 0xB4B4B4)!
                }
            } else {
                // No account or rejected. Red
                self.vBankAccountStatus.backgroundColor = UIColor(hex: 0xFA1001)!
            }
            self.vBankAccountStatus.isHidden = false
        }
    }

    private func loadDocuments() {
        documentsAreLoading = true
        reloadData()

        API.shared.checkDocumentsStaff { (docs, error) in
            if let error = error {
                if error.localizedDescription == "staff_not_enter_country" {
                    self.staffNotEnterCountry = true
                } else {
                    self.show(error: error)
                }
            }

            self.documentsAreLoading = false
            self.docs = docs
            self.reloadData()

            self.aiLoading.stopAnimating()
        }
    }

    func reloadData() {
        self.tvDocs.reloadData()
        var docsHeight = CGFloat(docs.count * 46)
        if self.staffNotEnterCountry {
            docsHeight += 100
            self.vFinishRegistration.isHidden = false
        } else {
            self.vFinishRegistration.isHidden = true
        }
        self.lcDocsHeight.constant = docsHeight
        self.view.layoutIfNeeded()
    }

    private func loadNotifications() {
        API.shared.loadUserInfo(force: true) { (profile, _) in
            self.swiSales.isOn = profile?.salesNotifications == "enabled"
            self.swiDailyResum.isOn = profile?.dailyResumNotifications == "enabled"
            self.swiPaymentNotifications.isOn = profile?.paymentsNotifications == "enabled"
        }
    }

    // Gestión de sale
    @IBAction func editRooms() {
        self.performSegue(withIdentifier: "StaffLocals", sender: StaffLocalsViewController.Mode.edit)
    }

    var blinkIdRecognizer: MBBlinkIdRecognizer?

    @IBAction func editEventsAndEntries() {
        self.performSegue(withIdentifier: "VerifyDNI", sender: self)
    }

    @IBAction func paymentInformation() {
        self.performSegue(withIdentifier: "StaffLocals", sender: StaffLocalsViewController.Mode.ventas)
    }

    @IBAction func changeBankAccount() {
        if !aiLoading.isAnimating {
            self.performSegue(withIdentifier: "BankAccount", sender: accounts.first)
        }
    }

    @IBAction func editEmployers() {
        performSegue(withIdentifier: "StaffEmployees", sender: nil)
    }

    @IBAction func editPromoCodes() {
        performSegue(withIdentifier: "StaffPromocodes", sender: nil)
    }

    @IBAction func facturas() {
        // performSegue(withIdentifier: "VerifyDNI", sender: nil)
        performSegue(withIdentifier: "StaffLocals", sender: StaffLocalsViewController.Mode.facturas)
    }

    @IBAction func continueRegistration() {
        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let loading = BlurryLoadingView.showAndStart()
            if StaffCountry.countryNames.isEmpty {
                StaffCountry.loadCountryNames(lang: "es")
            }

            API.shared.checkCountriesColaboration { (countries, error) in
                loading.stopAndHide()
                if let error = error {
                    self.show(error: error)
                }

                self.performSegue(withIdentifier: "StaffSelectCountry", sender: countries)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let staffViewDocumentVC = segue.destination as? StaffViewDocumentViewController,
           let document = sender as? StaffDocument {
            staffViewDocumentVC.document = document
        } else if let staffFillInContractVC = segue.destination as? StaffFillInContractViewController,
                  let document = sender as? StaffDocument {
            staffFillInContractVC.document = document
        } else if let staffUploadDocumentationVC = segue.destination as? StaffUploadDocumentationViewController,
                  let document = sender as? StaffDocument {
            staffUploadDocumentationVC.document = document
        } else if let staffBankAccountVC = segue.destination as? StaffBankAccountViewController {
            staffBankAccountVC.account = accounts.first
        } else if let staffLocalsVC = segue.destination as? StaffLocalsViewController,
                  let mode = sender as? StaffLocalsViewController.Mode {
            staffLocalsVC.mode = mode
        } else if let staffSelectCountryVC = segue.destination as? StaffSelectCountryViewController {
            staffSelectCountryVC.countries = sender as? [StaffCountry] ?? []
        } else if let staffViewDNIVC = segue.destination as? StaffViewDNIViewController,
                  let document = sender as? StaffDocument {
            staffViewDNIVC.document = document
        }
    }
}

extension StaffHomeViewController: SwiftySwitchDelegate {
    // Notificationes
    func valueChanged(sender: SwiftySwitch) {
        if sender.isOn {
            AppSound.toggleOn.play()
        } else {
            AppSound.toggleOff.play()
        }
        UIDevice.vibrate()

        let type: String
        switch sender {
        case swiDailyResum: type = "daily_resum"
        case swiPaymentNotifications: type = "payments"
        case swiSales: type = "sales"
        default: return
        }

        API.shared.updateNotificationSettings(type: type, isEnabled: sender.isOn)
    }
}

extension StaffHomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        docs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Document", for: indexPath) as? CellDocument
        cell?.prepare(document: docs[indexPath.row], isLoading: documentsAreLoading, delegate: self)
        return cell ?? UITableViewCell()
    }
}

extension StaffHomeViewController: CellDocumentDelegate {
    func documentSelected(_ document: StaffDocument) {
        switch document.status {
        case "waiting-review", "pending-review":
            let alert = UIAlertController(
                title: "alert.inRevision".localized,
                message: "alert.documentInReview".localized,
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "button.back".localized, style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)

        case "rejected":
            let rejectReason = document.rejectReason ?? "Unknown"
            let alert = UIAlertController(
                title: "alert.documentRejected".localized,
                message: "alert.documentRejectedDescription".localized.replacingOccurrences(of: "$rejectReason", with: rejectReason),
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "button.reenter".localized, style: .cancel) { (_) in
                self.openDocumentAsPending(document)
            })
            alert.addAction(UIAlertAction(title: "button.cancel".localized, style: .default, handler: nil))
            present(alert, animated: true, completion: nil)

        case "banned":
            let alert = UIAlertController(
                title: "alert.inRevision".localized,
                message: "alert.documentInReview".localized,
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "button.back".localized, style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)

        case "pending-send", "pending":
            self.openDocumentAsPending(document)

        default:
            if document.type == 2 {
                performSegue(withIdentifier: "DNIView", sender: document)
            } else {
                performSegue(withIdentifier: "ViewDocument", sender: document)
            }
        }
    }

    func openDocumentAsPending(_ document: StaffDocument) {
        switch document.type {
        case 1:
            performSegue(withIdentifier: "FillInContract", sender: document)

        case 2:
            performSegue(withIdentifier: "VerifyDNI", sender: document)

        default:
            performSegue(withIdentifier: "UploadDocumentation", sender: document)
        }
    }
}
