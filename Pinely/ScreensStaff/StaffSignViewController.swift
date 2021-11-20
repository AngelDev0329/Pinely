//
//  StaffSignViewController.swift
//  Pinely
//

import UIKit
import SignaturePad

protocol StaffSignDelegate: AnyObject {
    func sign(document: StaffDocument, signature: UIImage)
}

class StaffSignViewController: ViewController {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var signaturePad: SignaturePad!

    var document: StaffDocument!
    var signName: String!
    var signDNI: String!
    weak var delegate: StaffSignDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        lblTitle.text = "Yo, \(signName!) con DNI \(signDNI!) firmo en conformidad"
    }

    @IBAction func cleanSignature() {
        signaturePad.clear()
    }

    @IBAction func doneSigning() {
        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            guard let signature = self.signaturePad.getSignature() else {
                self.showError("No signature")
                return
            }

            self.delegate.sign(document: self.document, signature: signature)
            self.goBack()
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .landscape
    }
}
