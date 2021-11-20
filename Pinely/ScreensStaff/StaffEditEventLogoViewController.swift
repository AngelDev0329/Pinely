//
//  StaffEditEventLogoViewController.swift
//  Pinely
//

import UIKit
import SwiftEventBus

class StaffEditEventLogoViewController: ViewController {
    @IBOutlet weak var ivIconUpload: UIImageView!
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var vSaveChanges: UIView!

    var idLocal: Int!
    var selectedImage: UIImage?

    @IBAction func choosePicture() {
        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.selectPhotoFromGallery(croppingStyle: .none)
        }
    }

    override func photoSelected(image: UIImage?) {
        guard let image = image else {
            return
        }

        if image.size.width != 512 || image.size.height != 512 {
            let alert = UIAlertController(
                title: "Ups!",
                message: "Las dimensiones de la imagen que has seleccionado no son 512px x 512px",
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Entendido", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }

        selectedImage = image

        ivIconUpload.isHidden = true
        ivAvatar.image = image
        ivAvatar.isHidden = false
        vSaveChanges.isHidden = false
    }

    @IBAction func saveChanges() {
        guard let selectedImage = self.selectedImage,
              let jpgData = selectedImage.pngData()
        else { return }

        API.shared.uploadLocalImage(data: jpgData, idLocal: idLocal, type: "avatar") { (error) in
            if let error = error {
                print(error)
            } else {
                SwiftEventBus.post("localChanged")
            }
        }

        self.goBack()
    }
}
