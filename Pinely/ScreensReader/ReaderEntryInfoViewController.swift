//
//  ReaderEntryInfoViewController.swift
//  Pinely
//

import UIKit
import FirebaseStorage
import SwiftEventBus

// swiftlint:disable type_body_length
// swiftlint:disable file_length
class ReaderEntryInfoViewController: ViewController {
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var lblClientName: UILabel!
    @IBOutlet weak var ivUserVerified: UIImageView!

    @IBOutlet weak var tvRows: UITableView!
    @IBOutlet weak var lcRowsHeight: NSLayoutConstraint!

    @IBOutlet weak var lblComments: UILabel!
    @IBOutlet weak var vAddCommentButton: UIView!

    @IBOutlet weak var vRechazarLeft: UIView!
    @IBOutlet weak var vValidarLeft: UIView!
    @IBOutlet weak var vRechazarFull: UIView!

    @IBOutlet weak var vGreenFrame: UIView!

    let commentTapGestureRecogniser = UITapGestureRecognizer()
    let verifiedTapGestureRecognizer = UITapGestureRecognizer()

    struct SRow {
        var title: String
        var value: String
        var color: UIColor?
    }

    var rows: [SRow] = []

    enum ScreenType {
        case info
        case validating
        case validated
    }

    var sale: QRSale?
    var barcode: String?
    var eventId: Int?
    var screenType: ScreenType = .info
    var qrInfo: QRInfo?

    var acted = false

    var delegate: () -> Void = { } // swiftlint:disable:this weak_delegate

    private func showAvatarClient() {
        if let urlString = sale?.avatarClient {
            if urlString.starts(with: "http://") || urlString.starts(with: "https://"),
               let url = URL(string: urlString) {
                ivAvatar.kf.setImage(with: url)
            } else if urlString.starts(with: "gs://") {
                let storageRef = Storage.storage().reference(forURL: urlString)
                storageRef.downloadURL { [weak self] (url, _) in
                    if let url = url {
                        self?.ivAvatar.kf.setImage(with: url)
                    } else {
                        self?.ivAvatar.image = #imageLiteral(resourceName: "AvatarPinely")
                    }
                }
            } else {
                ivAvatar.image = #imageLiteral(resourceName: "AvatarPinely")
            }
        } else {
            ivAvatar.image = #imageLiteral(resourceName: "AvatarPinely")
        }
    }

    private func showInfoScreen() {
        vRechazarFull.isHidden = true
        vRechazarLeft.isHidden = false
        vValidarLeft.isHidden = false
        vGreenFrame.isHidden = true
        loadInfo()
    }

    private func showValidatingScreen() {
        vRechazarFull.isHidden = false
        vRechazarLeft.isHidden = true
        vValidarLeft.isHidden = true
        vGreenFrame.isHidden = true
        lblClientName.text = "Un momento..."
        lblComments.text = "..."

        if let barcode = barcode,
           let eventId = eventId {
            API.shared.validateQRCode(qrCode: barcode, idEvent: eventId) { [weak self] (qrInfo, error) in
                if let error = error {
                    self?.show(error: error, delegate: {
                        self?.goBack()
                    }, title: "Ups!")
                    return
                }

                self?.qrInfo = qrInfo
                self?.createRows()

                if qrInfo?.status == "ticket_already_validated" {
                    let alert = UIAlertController(
                        title: "alert.careful".localized,
                        message: "alert.ticketAlreadyValidated".localized,
                        preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    private func showValidatedScreen() {
        vRechazarFull.isHidden = false
        vRechazarLeft.isHidden = true
        vValidarLeft.isHidden = true
        vGreenFrame.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        showAvatarClient()

        switch screenType {
        case .info:
            showInfoScreen()

        case .validating:
            showValidatingScreen()

        case .validated:
            showValidatedScreen()
        }

        lblComments.isUserInteractionEnabled = true
        commentTapGestureRecogniser.addTarget(self, action: #selector(askComment))
        lblComments.addGestureRecognizer(commentTapGestureRecogniser)

        ivUserVerified.isUserInteractionEnabled = true
        verifiedTapGestureRecognizer.addTarget(self, action: #selector(showVerified))
        ivUserVerified.addGestureRecognizer(verifiedTapGestureRecognizer)

        createRows()
    }

    override func viewWillDisappear(_ animated: Bool) {
        if acted {
            SwiftEventBus.post("readerUpdated")
        }

        super.viewWillDisappear(animated)
    }

    private func createRowsWithQRInfo(_ qrInfo: QRInfo) {
        showQRInfo()

        let saleNumber = qrInfo.number
        let validatedTickets = qrInfo.validatedTickets
        let rejectedTickets = qrInfo.rejectedTickets
        let entriesLeft = saleNumber - (validatedTickets + rejectedTickets)

        rows.append(SRow(title: "Estado", value: qrInfo.getStatusText(), color: qrInfo.ticketStatus.getColor()))

        switch qrInfo.ticketStatus {
        case .validated:
            if let dateValidation = qrInfo.dateValidation {
                showValidationDate(date: dateValidation)
            }
            rows.append(SRow(title: "Evento", value: qrInfo.eventName, color: nil))
            showValidatedTickets(title: "Entradas validadas", amount: qrInfo.validatedTickets)
            rows.append(SRow(title: "Entradas por validar", value: "\(entriesLeft)", color: nil))

        case .rejected:
            if let dateRejection = qrInfo.dateRejection {
                showRejectionDate(date: dateRejection)
            }
            rows.append(SRow(title: "Evento", value: qrInfo.eventName, color: nil))
            showValidatedTickets(title: "Entradas rechazadas", amount: qrInfo.rejectedTickets)
            rows.append(SRow(title: "Entradas por validar", value: "\(entriesLeft)", color: nil))

        case .mixed:
            rows.append(SRow(title: "Evento", value: qrInfo.eventName, color: nil))
            showValidatedTickets(title: "Entradas validadas", amount: qrInfo.validatedTickets)
            showValidatedTickets(title: "Entradas rechazadas", amount: qrInfo.rejectedTickets)
            if let dateValidation = qrInfo.dateValidation {
                showValidationDate(date: dateValidation)
            }
            if let dateRejection = qrInfo.dateRejection {
                showRejectionDate(date: dateRejection)
            }

        case .notValidated:
            rows.append(SRow(title: "Evento", value: qrInfo.eventName, color: nil))
            rows.append(SRow(title: "Entradas por validar", value: "\(entriesLeft)", color: nil))
        }

        rows.append(SRow(title: "Tipo de entrada", value: qrInfo.nameTickets, color: nil))

        if qrInfo.ticketStatus == .notValidated,
           let finishValidationTicket = qrInfo.finishValidationTicket {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
            rows.append(SRow(title: "Limite de validación",
                             value: dateFormatter.string(from: finishValidationTicket),
                             color: nil))
        }

        rows.append(SRow(title: "Usuario", value: qrInfo.username, color: nil))

        if let date = qrInfo.birthDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let strDate = dateFormatter.string(from: date)
            rows.append(SRow(title: "Fecha de nacimiento", value: strDate, color: nil))
        }

        let strDNI: String
        if qrInfo.NIF.isEmpty || qrInfo.NIF.contains("null") {
            strDNI = "No ha introducido DNI"
        } else {
            strDNI = qrInfo.NIF
        }

        rows.append(SRow(title: "DNI", value: strDNI, color: nil))
    }

    fileprivate func createRowsWithoutQRInfo() {
        switch screenType {
        case .info:
            rows.append(SRow(title: "Estado", value: "...", color: nil))

        case .validating:
            rows.append(SRow(title: "Estado", value: "Validando", color: UIColor(hex: 0x03E218)!))

        case .validated:
            rows.append(SRow(title: "Estado", value: "...", color: nil))
        }
        rows.append(SRow(title: "Evento", value: "...", color: nil))
        rows.append(SRow(title: "Entradas por validar", value: "...", color: nil))
        rows.append(SRow(title: "Tipo de entrada", value: "...", color: nil))
        rows.append(SRow(title: "Usuario", value: "...", color: nil))
        rows.append(SRow(title: "Fecha de nacimiento", value: "...", color: nil))
        rows.append(SRow(title: "DNI", value: "...", color: nil))
    }

    func createRows() {
        rows.removeAll()

        if let qrInfo = self.qrInfo {
            createRowsWithQRInfo(qrInfo)
        } else {
            createRowsWithoutQRInfo()
        }

        showRows()
    }

    func showRows() {
        lcRowsHeight.constant = CGFloat(rows.count * 37)
        tvRows.reloadData()
        view.layoutIfNeeded()
    }

    func loadInfo() {
        guard let qrCode = barcode else {
            return
        }

        API.shared.checkQRInformation(qrCode: qrCode, idEvent: eventId ?? -1) { (qrInfo, error) in
            if let error = error {
                self.show(error: error, delegate: {
                    self.goBack()
                }, title: "Oops!")
                return
            }

            self.qrInfo = qrInfo
            self.createRows()
        }
    }

    private func showQRInfo() {
        guard let qrInfo = self.qrInfo else {
            return
        }

        lblClientName.text = qrInfo.clientName
        ivUserVerified.isHidden = !qrInfo.isUserVerified()

        if qrInfo.commentTicket.isEmpty {
            lblComments.text = "\n\n\n"
            vAddCommentButton.isHidden = false
        } else {
            lblComments.text = qrInfo.commentTicket
            vAddCommentButton.isHidden = true
        }

        if qrInfo.rangeValue == "show_buttons_action" {
            switch qrInfo.ticketStatus {
            case .validated, .mixed:
                vRechazarFull.isHidden = false
                vRechazarLeft.isHidden = true
                vValidarLeft.isHidden = true

            case .rejected:
                vRechazarFull.isHidden = true
                vRechazarLeft.isHidden = true
                vValidarLeft.isHidden = true

            case .notValidated:
                vRechazarFull.isHidden = true
                vRechazarLeft.isHidden = false
                vValidarLeft.isHidden = false
            }
        } else {
            vRechazarFull.isHidden = true
            vRechazarLeft.isHidden = true
            vValidarLeft.isHidden = true
        }
    }

    private func showValidationDate(date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        rows.append(SRow(title: "Fecha de validación", value: dateFormatter.string(from: date), color: nil))
    }

    private func showRejectionDate(date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        rows.append(SRow(title: "Fecha de rechazo", value: dateFormatter.string(from: date), color: nil))
    }

    private func showValidatedTickets(title: String, amount: Int) {
        rows.append(SRow(title: title, value: "\(amount)", color: nil))
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        delegate()
    }

    @IBAction func addComment(_ sender: Any) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.askComment()
        }
    }

    @objc func showVerified() {
        let alert = UIAlertController(
            title: "",
            message: "alert.informationVerified".localized,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    @objc func askComment() {
        guard let qrCode = self.barcode else {
            return
        }

        let alertController = UIAlertController(
            title: "Añadir comentario",
            message: "Puedes introducir comentarios para verlo luego",
            preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Ejemplo: He validado las 4 entradas, pero quedan 3 personas por venir"
        }

        let submitAction = UIAlertAction(title: "Enviar", style: .default) { [unowned alertController] _ in
            let answer = alertController.textFields?.first?.text ?? ""
            let loading = BlurryLoadingView.showAndStart()
            API.shared.commentTicketScanner(qrCode: qrCode, comment: answer) { (error) in
                loading.stopAndHide()
                if let error = error {
                    self.show(error: error)
                    return
                }

                self.loadInfo()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)

        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }

    private func endedWithError(isRejection: Bool, error: Error) {
        if error.localizedDescription == "ticket_out_range_validation" {
            let alert = UIAlertController(
                title: "alert.careful".localized,
                message: isRejection ?
                    "error.rejectionOutOfLimit".localized :
                    "error.validationOutOfLimit".localized,
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(
                title: isRejection ? "Rechazar" : "Validar",
                style: .default) { (_) in
                // No action required
            })
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            self.show(error: error)
        }
    }

    @IBAction func validate() {
        guard
            let qrCode = self.barcode ?? sale?.QRCode,
            let idEvent = self.eventId
            else { return }

        acted = true

        self.qrInfo = nil
        self.screenType = .validating
        createRows()
        vRechazarFull.isHidden = true
        vRechazarLeft.isHidden = true
        vValidarLeft.isHidden = true
        API.shared.validateQRCode(qrCode: qrCode, idEvent: idEvent) { (qrInfo, error) in
            if let error = error {
                self.endedWithError(isRejection: false, error: error)
            } else {
                self.qrInfo = qrInfo
                self.screenType = .validated
                self.createRows()

                if qrInfo?.status == "ticket_already_validated" {
                    let alert = UIAlertController(
                        title: "alert.careful".localized,
                        message: "Esta entrada ya ha sido validada antes, revisa la casilla Fecha de validación para saber a que hora fué validada",
                        preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    func performRejection(qrCode: String, idEvent: Int, amount: Int) {
        API.shared.rejectQRCode(qrCode: qrCode,
                                idEvent: idEvent,
                                numberToReject: amount) { (qrInfo, error) in
            if let error = error {
                self.endedWithError(isRejection: true, error: error)
            } else {
                self.qrInfo = qrInfo
                self.screenType = .validated
                self.createRows()
            }
        }
    }

    @IBAction func reject() {
        guard
            let qrCode = self.barcode ?? sale?.QRCode,
            let idEvent = self.eventId
            else { return }

        acted = true

        let loading = BlurryLoadingView.showAndStart()
        API.shared.checkHowManyTicketsYouCanReject(qrCode: qrCode) { (canReject, error) in
            if let error = error {
                loading.stopAndHide()
                self.show(error: error)
                return
            }

            guard let canReject = canReject,
                canReject > 0
            else {
                loading.stopAndHide()
                self.showError("Todas las entradas han sido rechazadas")
                return
            }

            loading.stopAndHide()
            let pickerData =
                (1...canReject).map {
                    ["value": "\($0)", "display": "\($0)"]
                }

            PickerDialog().show(title: "Entradas a rechazar",
                                options: pickerData, selected: "1") { (value) -> Void in
                let alert = UIAlertController(
                    title: "¡Atención!",
                    message: "Esta entrada se rechazará y el dinero se devolverá al cliente en su cuenta. ¿Quieres continuar?",
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Rechazar", style: .default) { (_) in
                    self.qrInfo = nil
                    self.screenType = .validating
                    self.createRows()
                    self.vRechazarFull.isHidden = true
                    self.vRechazarLeft.isHidden = true
                    self.vValidarLeft.isHidden = true
                    self.performRejection(qrCode: qrCode, idEvent: idEvent, amount: Int(value) ?? 1)
                })
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

extension ReaderEntryInfoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QRInfoRow", for: indexPath) as? CellQRInfoRow
        let row = rows[indexPath.row]
        cell?.prepare(title: row.title, value: row.value, color: row.color, isLast: indexPath.row >= rows.count - 1)
        return cell ?? UITableViewCell()
    }
}
