//
//  ReaderScanViewController.swift
//  Pinely
//

import UIKit
import SwiftEventBus

class ReaderScanViewController: ViewController {
    @IBOutlet weak var vCameraCanvas: UIView!

    let customerId = "OBI072720200001"
    var licenseKey = ""

    #if !targetEnvironment(simulator)
    var cdObject: CortexDecoderLibrary?
    var previewView: UIView?
    var torchOn = false
    #endif

    var canRead = false
    var eventId: Int?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.start()
    }

    func start() {
        #if !targetEnvironment(simulator)
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            // already authorized
            startCamera()
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    // access allowed
                    self.startCamera()
                } else {
                    // access denied
                }
            })
        }
        #endif
    }

    #if !targetEnvironment(simulator)
    private func startCamera() {
        if UIImagePickerController.isCameraDeviceAvailable( UIImagePickerController.CameraDevice.front) {
            DispatchQueue.main.async {
                self.cdObject = CortexDecoderLibrary.sharedObject()
                self.cdObject?.delegate = self

                self.cdObject?.setFocus(CD_Focus_Normal)
                self.cdObject?.setTorch(CD_Torch_Off)
                self.cdObject?.enableBeepPlayer(true)
                self.cdObject?.enableDecoding(true)
                self.cdObject?.enableVideoCapture(true)
                self.cdObject?.enableVibrate(onScan: true)
                self.cdObject?.ensureRegion(ofInterest: false)

                let pFrame = self.vCameraCanvas.bounds
                self.previewView = self.cdObject?.previewView(withFrame: pFrame)
                self.vCameraCanvas.addSubview(self.previewView!)

                self.canRead = true

                DispatchQueue.global().async {
                    self.cdObject?.startDecoding()
                }
            }
        }
    }
    #endif

    @IBAction func toggleTorch() {
        #if targetEnvironment(simulator)

        #else
        // Toggle torch
        if torchOn {
            toggleTorch(torchIsOn: false)
            torchOn = false
        } else {
            toggleTorch(torchIsOn: true)
            torchOn = true
        }
        #endif
    }

    private func toggleTorch(torchIsOn: Bool) {
        guard let device = AVCaptureDevice.default(for: .video) else {
            return
        }

        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                device.torchMode = torchIsOn ? .on : .off
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        #if !targetEnvironment(simulator)
        cdObject?.stopDecoding()
        #endif

        SwiftEventBus.post("readerUpdated")

        super.viewWillDisappear(animated)
    }

    override var preferredStatusBarStyleInternal: UIStatusBarStyle {
        .lightContent
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? ReaderEntryInfoViewController {
            let barcode = sender as? String
            viewController.barcode = barcode
            viewController.screenType = .validating
            viewController.delegate = { [weak self] in
                #if !targetEnvironment(simulator)
                self?.cdObject?.enableDecoding(true)
                #endif
                self?.canRead = true
            }
            viewController.eventId = eventId
        }
    }
}

#if !targetEnvironment(simulator)
extension ReaderScanViewController: CortexDecoderLibraryDelegate {
    func receivedMultiDecodedData(_ data: [Any]!, andType type: [Any]!) {
        if !canRead {
            return
        }

        let barcodes: [String] = data.compactMap {
            if let data = $0 as? Data {
                return String(data: data, encoding: .utf8)
            } else if let string = $0 as? String {
                return string
            } else {
                return nil
            }
        }

        if barcodes.isEmpty {
            return
        }

        // cdObject?.stopDecoding()
        canRead = false

        self.performSegue(withIdentifier: "Scanned", sender: barcodes[0])
    }

    func receivedDecodedData(_ data: Data!, andType type: CD_SymbologyType) {
        if let data = data {
            receivedMultiDecodedData([data], andType: [type])
        }
    }

    func configurationKeyData(_ requestedData: String!) -> String! {
        switch requestedData {
        case "customerID":
            return customerId

        case "configurationKey":
            return licenseKey

        default:
            return ""
        }
    }

    func receivedConfigFileError(_ error: String!) {
        print("Config file error: \(error ?? "unknown")")
    }

    func receivedBarcodeDecodeStatus(_ status: Bool) {
        // print("Barcode decode status: \(status)")
    }

    func receivedConfigFileActivationResult(_ licenseActivated: Bool) {
        print("Activation status: \(licenseActivated)")
        if licenseActivated {
            cdObject?.enableBeepPlayer(true)
            cdObject?.enableDecoding(true)
            cdObject?.enableVideoCapture(true)
            cdObject?.enableVibrate(onScan: true)
            cdObject?.enableDecoding(true)
        }
    }
}
#endif
