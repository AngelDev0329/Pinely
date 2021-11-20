//
//  StaffBankAccountViewController.swift
//  Pinely
//

import UIKit
import Alamofire
import MobileCoreServices

class StaffBankAccountViewController: ViewController {
    @IBOutlet weak var tfTitular: UITextField!
    @IBOutlet weak var tfIBAN: UITextField!
    @IBOutlet weak var vUploadDocument: UIView!
    @IBOutlet weak var vPreviewDocument: UIView!
    @IBOutlet weak var ivPreviewDocument: UIImageView!
    @IBOutlet weak var vChangeAccount: UIView!
    @IBOutlet weak var ivIBANValidationBadge: UIImageView!
    @IBOutlet weak var lcIBANValidationBadgeLeft: NSLayoutConstraint!

    var account: StaffBankAccount?
    var selectedDocument: URL?

    override func viewDidLoad() {
        super.viewDidLoad()

        showAccount()
    }

    private func showAccount() {
        if let account = account {
            // Show existing account
            if let urlString = account.URLDocument,
               let url = URL(string: urlString) {
                self.selectedDocument = url
            }

            tfTitular.text = account.titular ?? ""
            tfIBAN.text = account.IBAN ?? ""
            tfTitular.isEnabled = false
            tfIBAN.isEnabled = false
            vUploadDocument.isHidden = true
            vPreviewDocument.isHidden = false
            if let url = account.URLDocument,
               let urlURL = URL(string: url) {

                let fileManager = FileManager()

                let accountId = account.id ?? 0
                let pathComponent = "bank_doc_\(accountId).pdf"
                let directoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let folderPath: URL = directoryURL.appendingPathComponent("Downloads", isDirectory: true)
                let fileURL: URL = folderPath.appendingPathComponent(pathComponent)

                let destination: DownloadRequest.Destination = { _, _ in
                    return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
                }

                AF.download(urlURL, method: .get, parameters: nil,
                            encoding: URLEncoding.default, headers: nil,
                            interceptor: nil, requestModifier: nil, to: destination)
                    .response { _ in
                        if fileManager.fileExists(atPath: fileURL.absoluteString.replacingOccurrences(of: "file://", with: "")),
                           let pdfImage = UIImage.pdfImageWith(fileURL, pageNumber: 1, width: 360) {
                            self.ivPreviewDocument.image = pdfImage
                            self.ivPreviewDocument.backgroundColor = .white
                        }
                    }
            }
            vChangeAccount.isHidden = false
        } else {
            // Create new account
            tfTitular.text = ""
            tfIBAN.text = ""
            tfTitular.isEnabled = true
            tfIBAN.isEnabled = true
            vUploadDocument.isHidden = false
            vPreviewDocument.isHidden = true
            vChangeAccount.isHidden = true
        }
    }

    @IBAction func changeBankAccount() {
        UIDevice.vibrate()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.account = nil
            self.showAccount()
        }
    }

    @IBAction func uploadDocument() {
        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Adjuntar (.pdf)", style: .default) { (_) in
                let picker = UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF)], in: .import)
                picker.delegate = self
                picker.allowsMultipleSelection = false
                picker.modalPresentationStyle = .formSheet
                self.present(picker, animated: true, completion: nil)
            })
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = self.vUploadDocument
            }
            self.present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func previewDocument() {
        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let alert = UIAlertController(title: "Documento adjuntado", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Ver documento adjuntado", style: .default) { (_) in
                self.performSegue(withIdentifier: "StaffPDFPreview", sender: self)
            })
            alert.addAction(UIAlertAction(title: "Eliminar documento", style: .destructive) { (_) in
                self.selectedDocument = nil
                self.vUploadDocument.isHidden = false
                self.vPreviewDocument.isHidden = true
                self.vChangeAccount.isHidden = true
            })
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = self.vPreviewDocument
            }
            self.present(alert, animated: true, completion: nil)
        }
    }

    private func showIBANValidationBadge() {
        let ibanNumber = tfIBAN.text ?? ""
        lcIBANValidationBadgeLeft.constant = ibanNumber.width(withConstrainedHeight: 100, font: tfIBAN.font!) + 6
        ivIBANValidationBadge.isHidden = false
        view.layoutIfNeeded()
    }

    private func hideIBANValidationBadge() {
        ivIBANValidationBadge.isHidden = true
    }

    @IBAction func applyNewAccount() {
        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            guard let document = self.selectedDocument,
                  let documentData = try? Data(contentsOf: document, options: []) else {
                self.showError("Document not selected")
                return
            }

            let titular = self.tfTitular.text ?? ""
            let ibanNumber = self.tfIBAN.text ?? ""

            if titular.isEmpty {
                self.showError("Titular is not entered")
                return
            }

            if ibanNumber.isEmpty || !ibanNumber.isValidIBAN {
                self.showError("IBAN is not valid")
                return
            }

            let loadingView = LoadingView.showAndRun(text: "Estamos subiendo tu\ndocumentación, un momento...", viewController: self)
            API.shared.uploadBankDocument(titular: titular, ibanNumber: ibanNumber, data: documentData) { (account, error) in
                loadingView?.stopAndRemove()
                if let error = error {
                    self.show(error: error)
                    return
                }

                self.account = account
                self.showAccount()
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let staffPDFPreviewVC = segue.destination as? StaffPDFPreviewViewController {
            if let selectedDocument = self.selectedDocument {
                staffPDFPreviewVC.url = selectedDocument
            } else if let urlString = self.account?.URLDocument,
                      let url = URL(string: urlString) {
                staffPDFPreviewVC.url = url
                self.selectedDocument = url
            }
        }
    }
}

extension StaffBankAccountViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            return
        }

        self.selectedDocument = url

        if let pdfImage = UIImage.pdfImageWith(url, pageNumber: 1,
                                               width: ivPreviewDocument.bounds.width * UIScreen.main.scale) {
            self.vUploadDocument.isHidden = true
            self.vPreviewDocument.isHidden = false
            self.ivPreviewDocument.image = pdfImage
            self.vChangeAccount.isHidden = false
        }
    }
}

extension StaffBankAccountViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfTitular {
            tfIBAN.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == tfIBAN {
            if string.containsEmoji {
                return false
            }
            if string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                (string.contains(" ") || string.contains("\t") ||
                 string.contains("\r") || string.contains("\n")) {
                return false
            }
            if string.contains(" ") || string.contains("\t") || string.contains("\r") || string.contains("\n") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    let text = textField.text ?? ""
                    textField.text = String(text.filter { !" \n\t\r".contains($0) })
                }
            }
            return true
        } else {
            return true
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == tfIBAN {
            let ibanNumber = textField.text ?? ""
            if ibanNumber.isEmpty {
                return
            }
            let isValid = ibanNumber.isValidIBAN
            if isValid {
                self.showIBANValidationBadge()
            } else {
                self.hideIBANValidationBadge()
                textField.text = ""
                self.showError("El IBAN que has introducido parece que no es correcto, inténtalo de nuevo")
            }
        }
    }
}
