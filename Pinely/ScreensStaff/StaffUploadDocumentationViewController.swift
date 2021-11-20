//
//  StaffUploadDocumentationViewController.swift
//  Pinely
//

import UIKit
import SwiftEventBus
import MobileCoreServices

class StaffUploadDocumentationViewController: ViewController {
    @IBOutlet weak var vButtonBox: UIView!
    @IBOutlet weak var vDocumentPreview: UIView!
    @IBOutlet weak var ivDocumentPreview: UIImageView!
    @IBOutlet weak var vSendDocuments: UIView!
    @IBOutlet weak var lblDocumentTitle: UILabel!

    var document: StaffDocument!
    var selectedDocument: URL?

    override func viewDidLoad() {
        super.viewDidLoad()

        let fileName = document?.nameFile ?? "documento"
        lblDocumentTitle.text = "Subir \(fileName)"
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
                popoverController.sourceView = self.vButtonBox
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
                self.vButtonBox.isHidden = false
                self.vDocumentPreview.isHidden = true
                self.vSendDocuments.isHidden = true
            })
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = self.vDocumentPreview
            }
            self.present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func sendDocuments() {
        UIDevice.vibrate()

        guard let documentId = document.id,
              let documentUrl = self.selectedDocument,
              let documentData = try? Data(contentsOf: documentUrl)
        else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let loadingView = LoadingView.showAndRun(text: "Estamos subiendo tu\ndocumentación, un momento...", viewController: self)
            API.shared.uploadDocument(documentId: documentId, data: documentData) { (_, error) in
                loadingView?.stopAndRemove()

                if let error = error {
                    self.show(error: error)
                    return
                }

                SwiftEventBus.post("documentsChanged")
                self.goBack()
            }

        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let staffPDFPreviewVC = segue.destination as? StaffPDFPreviewViewController {
            staffPDFPreviewVC.url = selectedDocument
        }
    }
}

extension StaffUploadDocumentationViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            return
        }

        self.selectedDocument = url

        if let pdfImage = UIImage.pdfImageWith(url, pageNumber: 1, width: ivDocumentPreview.bounds.width * UIScreen.main.scale) {
            self.vButtonBox.isHidden = true
            self.vDocumentPreview.isHidden = false
            self.ivDocumentPreview.image = pdfImage
            self.vSendDocuments.isHidden = false
        }
    }
}
