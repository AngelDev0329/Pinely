//
//  SupportInvoiceViewController.swift
//  Pinely
//

import UIKit
import Alamofire
import FirebaseAuth

protocol SupportInvoiceViewControllerDelegate: AnyObject {
    func invoiceSent()
}

class SupportInvoiceViewController: ViewController {
    @IBOutlet weak var ivInvoice: UIImageView!
    @IBOutlet weak var aiLoading: UIActivityIndicatorView!
    @IBOutlet weak var vGetCopy: UIView!

    var question: SupportQuestion?
    var sale: Sale?
    weak var delegate: SupportInvoiceViewControllerDelegate?

    var piReference: String? {
        sale?.piReference
    }

    var pdfData: Data?

    fileprivate func showPdfData(_ pdfData: Data) {
        let fileUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("invoice.pdf")

        do {
            try pdfData.write(to: fileUrl)
            ivInvoice.fromPdf(
                fileUrl: fileUrl, page: 1,
                width: UIScreen.main.bounds.width * UIScreen.main.scale * 0.9,
                height: UIScreen.main.bounds.width * UIScreen.main.scale * 1.2)
        } catch {

        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let pdfData = pdfData {
            aiLoading.stopAnimating()
            self.vGetCopy.isHidden = false
            showPdfData(pdfData)
            return
        }

        if let pdfUrl = sale?.invoiceUrl,
           let url = URL(string: pdfUrl) {
            AF.request(url).responseData { (response) in
                self.aiLoading.stopAnimating()

                guard let pdfData = response.data else {
                    return
                }

                self.vGetCopy.isHidden = false
                self.pdfData = pdfData

                self.showPdfData(pdfData)
            }
        } else {
            aiLoading.stopAnimating()
        }
    }

    @IBAction func getInvoiceCopy() {
        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if let email = Auth.auth().currentUser?.email,
               let piReference = self.piReference {
                let alert = UIAlertController(title: "Enviar copia",
                                              message: "Enviaremos una copia a \(email) ¿Estás de acuerdo?",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancelar", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "Confirmar", style: .cancel, handler: { (_) in
                    API.shared.sendInvoiceCopyByEmail(piReference: piReference)
                    self.goBack()
                    self.delegate?.invoiceSent()
                }))
                self.present(alert, animated: true, completion: nil)
            } else if let pdfData = self.pdfData {
                let activityViewController = UIActivityViewController(
                        activityItems: [pdfData], applicationActivities: nil)

                // This lines is for the popover you need to show in iPad
                activityViewController.popoverPresentationController?.sourceView = self.vGetCopy
                if #available(iOS 13.0, *) {
                    activityViewController.isModalInPresentation = true
                }
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
    }
}
