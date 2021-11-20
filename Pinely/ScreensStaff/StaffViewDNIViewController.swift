//
//  StaffVerifyDNIViewController.swift
//  Pinely
//

import UIKit

class StaffViewDNIViewController: ViewController {

    @IBOutlet weak var ivDocumentFront: UIImageView!
    @IBOutlet weak var ivDocumentBack: UIImageView!
    @IBOutlet weak var lblSigned: UILabel!

    var document: StaffDocument!

    override func viewDidLoad() {
        super.viewDidLoad()

        ivDocumentFront.backgroundColor = .white
        if let urlString = document.urlDocumentUser1,
           let url = URL(string: urlString) {
            ivDocumentFront.kf.setImage(with: url)
        }
        ivDocumentBack.backgroundColor = .white
        if let urlString = document.urlDocumentUser2,
           let url = URL(string: urlString) {
            ivDocumentBack.kf.setImage(with: url)
        }

        if let date = document.dateSignature {
            let dfDate = DateFormatter()
            dfDate.dateFormat = "dd/MM/yyyy"
            let dfTime = DateFormatter()
            dfTime.dateFormat = "HH:mm"
            lblSigned.text = "Firmado el \(dfDate.string(from: date)) a las \(dfTime.string(from: date))"
        } else {
            lblSigned.text = "Firmado"
        }
    }

    @IBAction func viewFront() {
        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.performSegue(withIdentifier: "DNIPreview", sender: self.document.urlDocumentUser1)
        }
    }

    @IBAction func viewBack() {
        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.performSegue(withIdentifier: "DNIPreview", sender: self.document.urlDocumentUser2)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let staffDNIPreviewVC = segue.destination as? StaffDNIPreviewViewController {
            staffDNIPreviewVC.photoUrl = sender as? String
        }
    }
}
