//
//  StartCollaborationViewController.swift
//  Pinely
//

import UIKit
import FirebaseAuth

protocol StartCollaborationDelegate: AnyObject {
    func startCollaboration()
}

class StartCollaborationViewController: ViewController {
    @IBOutlet weak var lblTitle: UILabel!

    var username: String = ""
    weak var delegate: StartCollaborationDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        if username == "" {
            if let user = Auth.auth().currentUser,
                let name = user.displayName {
                username = name
            } else {
                username = "Usuario de Pinely"
            }
        }
        let fullTitle = "¡Hola \(username)!, estás apunto de unirte como uno de nuestros colaboradores y poder juntos llevar tu negocio al siguiente nivel."
        lblTitle.text = fullTitle
    }

    private func dismissAndStart() {
        self.dismiss(animated: true, completion: { [weak self] in
            self?.delegate?.startCollaboration()
        })
    }

    @IBAction func startCollaboration() {
        UIDevice.vibrate()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            let loading = BlurryLoadingView.showAndStart()
            API.shared.getUserRange { (range, error) in
                loading.stopAndHide()
                if let error = error {
                    self?.showErrorAndDismiss(error: error)
                    return
                }

                if range != "client" {
                    self?.showErrorAndDismiss(message: "error.rangeNotClient".localized)
                    return
                }

                self?.dismissAndStart()
            }
        }
    }
}
