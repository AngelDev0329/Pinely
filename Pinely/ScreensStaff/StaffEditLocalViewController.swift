//
//  StaffEditLocalViewController.swift
//  Pinely
//

import UIKit

class StaffEditLocalViewController: StaffCreateEditLocalBaseViewController {
    @IBOutlet weak var lblState: UILabel!
    @IBOutlet weak var vStateIndicator: UIView!

    var local: Local?
    var place: Place?

    override func viewDidLoad() {
        super.viewDidLoad()
        if local?.status == 1 {
            lblState.text = "Publicada"
            vStateIndicator.backgroundColor = UIColor(hex: 0x43e31c)!
        } else {
            lblState.text = "Ocultada al público"
            vStateIndicator.backgroundColor = UIColor(hex: 0xfa1001)!
        }

        tfType.text = place?.type.capitalized ?? ""
        tfName.text = local?.localName ?? place?.name ?? ""
        tfSlogan.text = local?.subTitle ?? local?.subTitle ?? ""
        tvDescription.text = local?.information ?? ""

        lblDescriptionHint.isHidden = !(tvDescription.text ?? "").isEmpty
    }

    override func lastFieldDone() {
        editInformation()
    }

    @IBAction func editInformation() {
        view.endEditing(true)

        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let name = self.tfName.text ?? ""
            if name.count < 3 {
                self.showError("El nombre de tu sala tiene que ser mayor a 3 carácteres")
                return
            }

            self.goBack()
        }
    }

    @IBAction func eliminateLocal() {
        // TODO
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let staffEditEventLogoVC = segue.destination as? StaffEditEventLogoViewController {
            staffEditEventLogoVC.idLocal = place!.id
        } else if let staffChangeCoverVC = segue.destination as? StaffChangeCoverViewController {
            staffChangeCoverVC.idLocal = place!.id
        }
    }
}
