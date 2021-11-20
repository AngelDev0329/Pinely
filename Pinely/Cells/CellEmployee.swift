//
//  CellEmployee.swift
//  Pinely
//

import UIKit
import FirebaseStorage

protocol CellEmployeeDelegate: AnyObject {
    func employeeSelected(employee: Employee)
}

class CellEmployee: UICollectionViewCell {
    @IBOutlet weak var ivPicture: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var vFrame: UIView!
    @IBOutlet weak var vFrameFront: UIView!
    @IBOutlet weak var vAvatarShade: UIView!
    @IBOutlet weak var lcWidth: NSLayoutConstraint!

    var employee: Employee?
    weak var delegate: CellEmployeeDelegate?

    func prepare(employee: Employee, delegate: CellEmployeeDelegate) {
        self.employee = employee
        self.delegate = delegate

        lcWidth.constant = UIScreen.main.bounds.width - 56
        lblName.font = AppFont.semiBold[10]
        lblStatus.font = AppFont.regular[10]
        lblName.text = employee.name
        if let urlString = employee.avatar {
            if urlString.starts(with: "http://") || urlString.starts(with: "https://"),
                let url = URL(string: urlString) {
                ivPicture.kf.setImage(with: url)
            } else if urlString.starts(with: "gs://") {
                let storageRef = Storage.storage().reference(forURL: urlString)
                storageRef.downloadURL { [weak self] (url, _) in
                    if let url = url {
                        self?.ivPicture.kf.setImage(with: url)
                    } else {
                        self?.ivPicture.image = #imageLiteral(resourceName: "AvatarPinely")
                    }
                }
            } else {
                ivPicture.image = #imageLiteral(resourceName: "AvatarPinely")
            }
        } else {
            ivPicture.image = #imageLiteral(resourceName: "AvatarPinely")
        }

        switch employee.range {
        case "reader": lblStatus.text = "Lector de códigos QR"
        case "revisor": lblStatus.text = "Revisor de fotos"
        case "staff": lblStatus.text = "Administrador"
        default: lblStatus.text = "?"
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.vFrame.updateShadow()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.vFrame.updateShadow()
    }

    @IBAction func employeeSelected() {
        if let employee = self.employee {
            delegate?.employeeSelected(employee: employee)
        }
    }

    func massCancelClick() {
        vFrame.cancelClick()
        vFrameFront.cancelClick()
    }
}
