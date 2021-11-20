//
//  StaffVerifyDNIViewController.swift
//  Pinely
//

import UIKit
import Microblink
import SwiftEventBus
import MobileCoreServices

class StaffVerifyDNIViewController: ViewController {

    @IBOutlet weak var ivDocumentFront: UIImageView!
    @IBOutlet weak var ivDocumentBack: UIImageView!
    @IBOutlet weak var vUpload: UIView!

    enum DocumentSide {
        case back
        case front
    }

    struct Document {
        var side: DocumentSide
        var image: UIImage
        var url: URL?
    }

    var documents: [DocumentSide: Document] = [:]

    var documentSide: DocumentSide = .back

    @IBAction func uploadDocumentFront() {
        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.documentSide = .front
            self.uploadSomething()
        }
    }

    @IBAction func uploadDocumentBack() {
        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.documentSide = .back
            self.uploadSomething()
        }
    }

    private func uploadSomething() {
        let title: String
        let imageView: UIImageView
        switch documentSide {
        case .front:
            title = "Parte frontal"
            imageView = ivDocumentFront

        case .back:
            title = "Parte trasera"
            imageView = ivDocumentBack
        }

        if documents[documentSide] != nil {
            let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Ver foto realizada", style: .default) { (_) in
                self.performSegue(withIdentifier: "DNIPreview", sender: self)
            })
            alert.addAction(UIAlertAction(title: "Eliminar foto", style: .destructive) { (_) in
                imageView.image = nil
                imageView.backgroundColor = .clear
                self.documents.removeValue(forKey: self.documentSide)
            })
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = imageView
            }
            present(alert, animated: true, completion: nil)
            return
        }

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Escanear con la cámara", style: .default) { (_) in
            let loading = BlurryLoadingView.showAndStart()
            API.shared.checkMicroblinkSerial { (serial, error) in
                loading.stopAndHide()
                if let error = error {
                    self.show(error: error)
                    return
                }

                self.performSegue(withIdentifier: "DNIPhoto", sender: serial)
            }
        })
        alert.addAction(UIAlertAction(title: "Subir desde la galería", style: .default) { (_) in
            self.selectPhotoFromGallery(croppingStyle: .default)
        })
//        alert.addAction(UIAlertAction(title: "Subir archivo .PDF", style: .default) { (_) in
//            let picker = UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF)], in: .import)
//            picker.delegate = self
//            picker.allowsMultipleSelection = false
//            picker.modalPresentationStyle = .formSheet
//            self.present(picker, animated: true, completion: nil)
//        })
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = imageView
        }
        present(alert, animated: true, completion: nil)
    }

    override func photoSelected(image: UIImage?) {
        if let image = image {
            self.showPhoto(image: image)
        }
    }

    private func showPhoto(image: UIImage, originUrl: URL? = nil) {
        switch documentSide {
        case .back:
            self.ivDocumentBack.backgroundColor = .white
            self.ivDocumentBack.image = image

        case .front:
            self.ivDocumentFront.backgroundColor = .white
            self.ivDocumentFront.image = image
        }

        documents[documentSide] = Document(side: documentSide, image: image, url: originUrl)
        if documents.keys.count == 2 {
            vUpload.isHidden = false
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let staffPhotoDNIVC = segue.destination as? StaffPhotoDNIViewController {
            staffPhotoDNIVC.delegate = self
            staffPhotoDNIVC.microblinkSerial = (sender as? String) ?? ""
            switch documentSide {
            case .front:
                staffPhotoDNIVC.frontOnly = true

            case .back:
                staffPhotoDNIVC.backOnly = true
            }
        } else if let staffDNIPreviewVC = segue.destination as? StaffDNIPreviewViewController {
            switch documentSide {
            case .front: staffDNIPreviewVC.photoTitle = "Parte frontal"
            case .back: staffDNIPreviewVC.photoTitle = "Parte trasera"
            }
            staffDNIPreviewVC.photoImage = documents[documentSide]?.image
        }
    }

    @IBAction func uploadDocuments() {
        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let loadingView = LoadingView.showAndRun(text: "Estamos subiendo tu\ndocumentación, un momento...", viewController: self)
            let frontal: Any = self.documents[.front]!.url ?? self.documents[.front]!.image
            let trasero: Any = self.documents[.back]!.url ?? self.documents[.back]!.image
            API.shared.uploadDNIStaff(frontal: frontal, trasero: trasero) { (error) in
                loadingView?.stopAndRemove()

                if let error = error {
                    self.show(error: error)
                } else {
                    SwiftEventBus.post("documentsChanged")
                    self.goBack()
                }
            }
        }
    }
}

extension StaffVerifyDNIViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first,
           let pdfImage = UIImage.pdfImageWith(
            url, pageNumber: 1, width: ivDocumentFront.bounds.width * UIScreen.main.scale) {
            self.showPhoto(image: pdfImage, originUrl: url)
        }
    }
}

extension StaffVerifyDNIViewController: StaffPhotoDNIViewControllerDelegate {
    func frontPhotoTaken(image: UIImage?, recognitionResult: MBBlinkIdRecognizerResult?) {
        documentSide = .front
        photoTaken(image: image, recognitionResult: recognitionResult)
    }

    func backPhotoTaken(image: UIImage?, recognitionResult: MBBlinkIdRecognizerResult?) {
        documentSide = .back
        photoTaken(image: image, recognitionResult: recognitionResult)
    }

    func photoTaken(image: UIImage?, recognitionResult: MBBlinkIdRecognizerResult?) {
        if let image = image {
            self.showPhoto(image: image)
        }
    }
}
