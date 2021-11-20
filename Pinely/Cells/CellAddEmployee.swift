//
//  CellAddEmployee.swift
//  Pinely
//

import UIKit

protocol CellAddEmployeeDelegate: AnyObject {
    func addEmployee()
}

class CellAddEmployee: UICollectionViewCell {
    @IBOutlet weak var vFrame: UIView!
    @IBOutlet weak var vFrameFront: UIView!
    @IBOutlet weak var lcWidth: NSLayoutConstraint!

    weak var delegate: CellAddEmployeeDelegate?

    func prepare(delegate: CellAddEmployeeDelegate) {
        self.delegate = delegate

        lcWidth.constant = UIScreen.main.bounds.width - 56

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.vFrame.updateShadow()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.vFrame.updateShadow()
    }

    @IBAction func addEmployee() {
        delegate?.addEmployee()
    }

    func massCancelClick() {
        vFrame.cancelClick()
        vFrameFront.cancelClick()
    }
}
