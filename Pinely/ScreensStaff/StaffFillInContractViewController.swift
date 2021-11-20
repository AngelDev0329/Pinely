//
//  StaffFillInContractViewController.swift
//  Pinely
//

import UIKit
import SwiftEventBus

class StaffFillInContractViewController: ViewController {
    @IBOutlet weak var svFormContainer: UIScrollView!
    @IBOutlet weak var tfType: UITextField!
    @IBOutlet weak var tfPerson: UITextField!
    @IBOutlet weak var tfAddress: UITextField!
    @IBOutlet weak var tfDNI: UITextField!
    @IBOutlet weak var tfCompany: UITextField!
    @IBOutlet weak var tfCompanyAddress: UITextField!
    @IBOutlet weak var tfCIF: UITextField!
    @IBOutlet weak var tfBrand: UITextField!
    @IBOutlet weak var lcBottom: NSLayoutConstraint!

    @IBOutlet weak var lblCompany: UILabel!
    @IBOutlet weak var lblCIF: UILabel!
    @IBOutlet weak var lblCompanyAddress: UILabel!
    @IBOutlet weak var vCompany: UIView!
    @IBOutlet weak var vCIF: UIView!
    @IBOutlet weak var vCompanyAddress: UIView!
    @IBOutlet weak var lcBrandTop: NSLayoutConstraint!

    var document: StaffDocument!

    let typePicker = UIPickerView()

    override func viewDidLoad() {
        super.viewDidLoad()

        typePicker.delegate = self
        typePicker.dataSource = self
        tfType.inputView = typePicker

        addDoneButtonOnKeyboard()

        companyMode()
    }

    private func companyMode() {
        lblCompany.isHidden = false
        lblCIF.isHidden = false
        lblCompanyAddress.isHidden = false
        vCompany.isHidden = false
        vCIF.isHidden = false
        vCompanyAddress.isHidden = false
        tfCompany.isHidden = false
        tfCIF.isHidden = false
        tfCompanyAddress.isHidden = false
        lcBrandTop.constant = 264
        view.layoutIfNeeded()
    }

    private func personalMode() {
        lblCompany.isHidden = true
        lblCIF.isHidden = true
        lblCompanyAddress.isHidden = true
        vCompany.isHidden = true
        vCIF.isHidden = true
        vCompanyAddress.isHidden = true
        tfCompany.isHidden = true
        tfCIF.isHidden = true
        tfCompanyAddress.isHidden = true
        lcBrandTop.constant = 48
        view.layoutIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(StaffFillInContractViewController.keyboardWillShow(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(StaffFillInContractViewController.keyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)

        super.viewWillDisappear(animated)
    }

    @objc func keyboardWillShow(notification: Notification) {
        var keyboardHeight: CGFloat = 220
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight =  keyboardSize.height
        }

        lcBottom.constant = keyboardHeight
        view.layoutIfNeeded()
    }

    @objc func keyboardWillHide(notification: Notification) {
        lcBottom.constant = 80
        view.layoutIfNeeded()
    }

    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Aceptar", style: .done, target: self, action: #selector(self.doneButtonAction))

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        tfType.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction() {
        tfPerson.becomeFirstResponder()
    }

    private func handleDocumentCreationResult(_ error: Error?, _ newDocuments: [StaffDocument]) {
        if let error = error {
            self.show(error: error)
            return
        }

        SwiftEventBus.post("documentsChanged")
        if let document = newDocuments.first {
            self.performSegue(withIdentifier: "ViewDocument", sender: document)
        } else {
            self.goBack()
        }
    }

    @IBAction func generateDocument(_ sender: Any) {
        guard let type = tfType.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            !type.isEmpty else {
            self.showWarning("Missing type")
            return
        }

        guard let personName = tfPerson.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            personName.count >= 5 else {
            self.showWarning("Introduce nombres y apellidos del representante válidos")
            return
        }

        guard let address = tfAddress.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            address.count >= 5 else {
            self.showWarning("Introduce un domicilio del representante válido")
            return
        }

        guard let dni = tfDNI.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            dni.count >= 5 else {
            self.showWarning("Introduce un DNI del representante válido")
            return
        }

        var company = ""
        var companyAddress = ""
        var cif = ""

        if type == "Empresa" {
            guard let companyText = tfCompany.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                companyText.count >= 5 else {
                self.showWarning("Introduce un nombre de empresa válido")
                return
            }

            guard let cifText = tfCIF.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                cifText.count >= 5 else {
                self.showWarning("Introduce un CIF de empresa válido")
                return
            }

            guard let companyAddressText = tfCompanyAddress.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  companyAddressText.count >= 5 else {
                self.showWarning("Introduce una dirección de empresa válida")
                return
            }

            company = companyText
            cif = cifText
            companyAddress = companyAddressText
        }

        guard let brand = tfBrand.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            brand.count >= 3 else {
            self.showWarning("Introduce una marca o nombre de la sala válido")
            return
        }

        let loadingView = LoadingView.showAndRun(text: "Estamos preparando la\ndocumentación, un momento...", viewController: self)
        let args = GenerateDocumentsArguments(documentId: document.id!, type: type,
                                              nameAgent: personName, addressAgent: address,
                                              dniAgent: dni, businessName: company,
                                              addressBusiness: companyAddress, cif: cif,
                                              brand: brand)
        API.shared.generateDocument(args) { [weak self] (newDocuments, error) in
            loadingView?.stopAndRemove()

            self?.handleDocumentCreationResult(error, newDocuments)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let staffViewDocumentVC = segue.destination as? StaffViewDocumentViewController,
           let document = sender as? StaffDocument {
            staffViewDocumentVC.document = document
        }
    }

    static let pickerOptions = [
        "Empresa",
        "Autónomo",
        "Particular"
    ]
}

extension StaffFillInContractViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        StaffFillInContractViewController.pickerOptions.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        StaffFillInContractViewController.pickerOptions[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        tfType.text = StaffFillInContractViewController.pickerOptions[row]
    }
}

extension StaffFillInContractViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == tfType {
            switch textField.text {
            case "Empresa": companyMode()
            case "Autónomo": personalMode()
            case "Particular":
                self.showError("Actualmente solo admitimos a Empresas y Autónomos para que puedan colaborar con nosotros.", delegate: {
                    self.tfType.text = ""
                }, title: "Ups!")
            default:
                break
            }
        }
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == tfType,
            (textField.text ?? "").isEmpty {
            textField.text = StaffFillInContractViewController.pickerOptions.first ?? ""
        }

        var offset = CGFloat(0)
        switch textField {
        case tfType: offset = 0
        case tfPerson: offset = 0
        case tfAddress: offset = 40
        case tfDNI: offset = 80
        case tfCompany: offset = 120
        case tfCIF: offset = 160
        case tfCompanyAddress: offset = 200
        case tfBrand: if tfCompany.isHidden {
            offset = 120
        } else {
            offset = 240
        }
        default: offset = 0
        }

        svFormContainer.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case tfType: tfPerson.becomeFirstResponder()
        case tfPerson: tfAddress.becomeFirstResponder()
        case tfAddress: tfDNI.becomeFirstResponder()
        case tfDNI:
            if tfCompany.isHidden {
                tfBrand.becomeFirstResponder()
            } else {
                tfCompany.becomeFirstResponder()
            }
        case tfCompany: tfCompanyAddress.becomeFirstResponder()
        case tfCompanyAddress: tfCIF.becomeFirstResponder()
        case tfCIF: tfBrand.becomeFirstResponder()
        case tfBrand: textField.resignFirstResponder()
        default: textField.resignFirstResponder()
        }

        return false
    }

    private func validateInput(_ updatedText: String, _ textField: UITextField) -> Bool {
        if updatedText.containsEmoji {
            return false
        }

        switch textField {
        case tfPerson:
            if updatedText.count > 60 {
                return false
            }

        case tfAddress, tfCompanyAddress:
            if updatedText.count > 85 {
                return false
            }

        case tfDNI, tfCompany, tfCIF, tfBrand:
            if updatedText.count > 50 {
                return false
            }

        default:
            break
        }

        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
           let textRange = Range(range, in: text) {
           let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)

            return validateInput(updatedText, textField)
        }
        return true
    }
}
