//
//  StaffViewDocumentViewController.swift
//  Pinely
//

import UIKit
import WebKit
import SwiftEventBus

class StaffViewDocumentViewController: StaffViewInWebViewBaseViewController {
    @IBOutlet weak var vSignDocument: UIView!
    @IBOutlet weak var vDocumentSigned: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSigned: UILabel!

    var document: StaffDocument!

    override func viewDidLoad() {
        super.viewDidLoad()

        loadDocument()

        lblTitle.text = document.nameFile ?? ""
    }

    func loadDocument() {
        var urlPinely: String?
        if document.type == 3 {
            urlPinely = document.urlDocumentUser1
        } else {
            urlPinely = document.urlDocumentPinely
        }
        if let pdfUrlString = urlPinely,
            let pdfUrl = URL(string: pdfUrlString) {
            let request = URLRequest(url: pdfUrl)
            aiLoading.startAnimating()
            wvPDF.navigationDelegate = self
            wvPDF.load(request)
        } else {
            aiLoading.stopAnimating()
        }

        switch document.status {
        case "pending-send", "pending", "rejected":
            vSignDocument.isHidden = false
            vDocumentSigned.isHidden = true

        case "aproved", "approved", "waiting-review":
            var text = ""
            if let date = document.dateSignature {
                let dfDate = DateFormatter()
                dfDate.dateFormat = "dd/MM/yyyy"
                let dfTime = DateFormatter()
                dfTime.dateFormat = "HH:mm"
                text = "Firmado el \(dfDate.string(from: date)) a las \(dfTime.string(from: date))"
            }

            if document.type == 1,
               let legalCertificate = document.legalCertificate,
               URL(string: legalCertificate) != nil {

                if !text.isEmpty {
                    text += "\n"
                }
                text += "Ver certificado electrónico"
            }

            vSignDocument.isHidden = true
            if text.isEmpty {
                vDocumentSigned.isHidden = true
            } else {
                lblSigned.text = text
                vDocumentSigned.isHidden = false
            }

        default:
            vSignDocument.isHidden = true
            vDocumentSigned.isHidden = true
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let navigationController = self.navigationController {
            self.navigationController?.viewControllers = navigationController
                .viewControllers.filter { !($0 is StaffFillInContractViewController) }
        }
    }

    @IBAction func signDocument() {
        UIDevice.vibrate()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.askWhoSigns()
        }
    }

    @IBAction func showCertificate() {
        UIDevice.vibrate()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.performSegue(withIdentifier: "ViewCertificate", sender: self)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let staffSignVC = segue.destination as? StaffSignViewController {
            staffSignVC.signName = whoSigns
            staffSignVC.signDNI = dni
            staffSignVC.document = document
            staffSignVC.delegate = self
        } else if let staffViewCertificateVC = segue.destination
                    as? StaffViewCertificateViewController,
                  let legalCertificate = document.legalCertificate,
                  let url = URL(string: legalCertificate) {
            staffViewCertificateVC.url = url
        }
    }

    var whoSigns = ""
    var dni = ""

    func askWhoSigns() {
        if let name = document?.nameAgent {
            self.whoSigns = name
            self.askDNI()
            return
        }

        let alert = UIAlertController(title: "alert.whoSigns".localized,
                                      message: "alert.nameOfSigningPerson".localized,
                                      preferredStyle: .alert)
        alert.addTextField { (textField: UITextField!) -> Void in
            textField.returnKeyType = .done
        }
        alert.addAction(UIAlertAction(title: "button.cancel".localized, style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "button.next".localized, style: .cancel) { (_) in
            guard
                let textField = alert.textFields?.first,
                let result = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                !result.isEmpty
                else { return }
            self.whoSigns = result
            self.askDNI()
        })
        self.present(alert, animated: true, completion: nil)
    }

    func askDNI() {
        if let dni = document?.DNIAgent {
            self.dni = dni
            self.performSegue(withIdentifier: "Sign", sender: self)
            return
        }

        let alert = UIAlertController(title: "alert.identification".localized,
                                      message: "alert.indicateDNI".localized,
                                      preferredStyle: .alert)
        alert.addTextField { (textField: UITextField!) -> Void in
            textField.returnKeyType = .done
        }
        alert.addAction(UIAlertAction(title: "button.cancel".localized, style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "button.next".localized, style: .cancel) { (_) in
            guard
                let textField = alert.textFields?.first,
                let result = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                !result.isEmpty
                else { return }
            self.dni = result
            self.performSegue(withIdentifier: "Sign", sender: self)
        })
        self.present(alert, animated: true, completion: nil)
    }
}

extension StaffViewDocumentViewController: StaffSignDelegate {
    func sign(document: StaffDocument, signature: UIImage) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let loadingView = LoadingView.showAndRun(text: "loading.signContract".localized, viewController: self)
            API.shared.signContract(documentId: self.document.id!, signature: signature) { (newDocument, error) in
                loadingView?.stopAndRemove()

                if let error = error {
                    self.show(error: error)
                    return
                }

                if let document = newDocument.first {
                    self.document = document
                    self.loadDocument()
                }

                SwiftEventBus.post("documentsChanged")
            }
        }
    }
}
