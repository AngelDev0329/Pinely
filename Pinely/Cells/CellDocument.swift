//
//  CellDocument.swift
//  Pinely
//

import UIKit

protocol CellDocumentDelegate: AnyObject {
    func documentSelected(_ document: StaffDocument)
}

class CellDocument: UITableViewCell {
    @IBOutlet weak var btnDocumentName: UIButton!
    @IBOutlet weak var vDocumentStatus: UIView!
    @IBOutlet weak var aiLoading: UIActivityIndicatorView!

    var document: StaffDocument?
    weak var delegate: CellDocumentDelegate?

    func prepare(document: StaffDocument, isLoading: Bool, delegate: CellDocumentDelegate?) {
        self.document = document
        self.delegate = delegate

        if isLoading {
            vDocumentStatus.isHidden = true
            aiLoading.startAnimating()
        } else {
            vDocumentStatus.backgroundColor = document.bubbleColor
            vDocumentStatus.isHidden = false
            aiLoading.stopAnimating()
        }

        btnDocumentName.setTitle(document.nameFile ?? "", for: .normal)
    }

    @IBAction func showDocument() {
        if let document = document {
            delegate?.documentSelected(document)
        }
    }
}
