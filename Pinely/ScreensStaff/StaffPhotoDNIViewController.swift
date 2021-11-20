//
//  StaffPhotoDNIViewController.swift
//  Pinely
//

import UIKit
import Microblink
import AVFoundation

protocol StaffPhotoDNIViewControllerDelegate: AnyObject {
    func frontPhotoTaken(image: UIImage?, recognitionResult: MBBlinkIdRecognizerResult?)
    func backPhotoTaken(image: UIImage?, recognitionResult: MBBlinkIdRecognizerResult?)
}

class StaffPhotoDNIViewController: ViewController {
    @IBOutlet weak var vCameraCanvas: UIView!

    @IBOutlet weak var ivBack: UIImageView!
    @IBOutlet weak var ivFront: UIImageView!

    @IBOutlet weak var lblBottomText: UILabel!

    weak var delegate: StaffPhotoDNIViewControllerDelegate?

    var recognizerRunner: MBRecognizerRunner?
    var recognizer: MBBlinkIdRecognizer?

    var captureSession: AVCaptureSession!
    var captureDateOutput: AVCaptureVideoDataOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!

    var scannedImage: UIImage?

    var processing = false

    var frontOnly = false
    var backOnly = false

    var frontDone = false
    var backDone = false

    var microblinkSerial = ""

    #if !targetEnvironment(simulator)
    var torchOn = false
    #endif

    override func viewDidLoad() {
        super.viewDidLoad()

        MBMicroblinkSDK.shared().setLicenseKey(microblinkSerial)
        MBMicroblinkSDK.shared().showLicenseKeyTimeLimitedWarning = false

        if frontOnly {
            lblBottomText.text = "Coloca la parte frontal del documento\nsobre el marco para escanearlo"
        } else if backOnly {
            lblBottomText.text = "Coloca la parte trasera del documento\nsobre el marco para escanearlo"
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo

        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
        else {
            self.showError("Can't access camera", delegate: {
                self.goBack()
            }, title: "Ups!")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            captureDateOutput = AVCaptureVideoDataOutput()
            captureDateOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            captureDateOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)

            if captureSession.canAddInput(input) /* && captureSession.canAddOutput(stillImageOutput) */ {
                captureSession.addInput(input)
                if captureSession.canAddOutput(captureDateOutput) {
                    captureSession.addOutput(captureDateOutput)
                }
                setupLivePreview()
            }
        } catch let error {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
    }

    private func setupLivePreview() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)

        videoPreviewLayer.videoGravity = .resizeAspectFill

        let videoOrientation: AVCaptureVideoOrientation
        switch UIDevice.current.orientation {
        case .unknown:
            videoOrientation = .portrait
        case .portrait:
            videoOrientation = .portrait
        case .portraitUpsideDown:
            videoOrientation = .portraitUpsideDown
        case .landscapeLeft:
            videoOrientation = .landscapeLeft
        case .landscapeRight:
            videoOrientation = .landscapeRight
        case .faceUp:
            videoOrientation = .portrait
        case .faceDown:
            videoOrientation = .portraitUpsideDown
        @unknown default:
            videoOrientation = .portrait
        }
        videoPreviewLayer.connection?.videoOrientation = videoOrientation
        vCameraCanvas.layer.addSublayer(videoPreviewLayer)

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()

            DispatchQueue.main.async { [weak self] in
                if let safeSelf = self {
                    safeSelf.videoPreviewLayer.frame = safeSelf.vCameraCanvas.bounds
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.captureSession.stopRunning()
    }

    @IBAction func toggleFlash() {
        #if !targetEnvironment(simulator)
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

    #if !targetEnvironment(simulator)
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
    #endif

    override var preferredStatusBarStyleInternal: UIStatusBarStyle {
        .lightContent
    }
}

extension StaffPhotoDNIViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        // dispose system shutter sound
        AudioServicesDisposeSystemSoundID(1108)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        processing = false
    }

    func processPhoto(image: UIImage) {
        self.scannedImage = image

        var recognizers = [MBRecognizer]()
        recognizer = MBBlinkIdRecognizer()
        recognizers.append(recognizer!)
        let recognizerCollection = MBRecognizerCollection(recognizers: recognizers)

        recognizerRunner = MBRecognizerRunner(recognizerCollection: recognizerCollection)
        recognizerRunner?.scanningRecognizerRunnerDelegate = self

        let mbImage = MBImage(uiImage: image)
        mbImage.cameraFrame = false
        mbImage.orientation = MBProcessingOrientation.up
        let serialQueue = DispatchQueue(label: "com.pinely.microblink")
        serialQueue.async(execute: {() -> Void in
            self.recognizerRunner?.processImage(mbImage)
        })
    }
}

extension StaffPhotoDNIViewController: MBScanningRecognizerRunnerDelegate {
    func recognizerRunner(_ recognizerRunner: MBRecognizerRunner, didFinishScanningWith state: MBRecognizerResultState) {
        switch state {
        case .valid, .uncertain:
            DispatchQueue.main.async {
                var done = false
                if self.isFront() {
                    if !self.backOnly {
                        // Add as front
                        self.ivFront.image = self.scannedImage
                        self.delegate?.frontPhotoTaken(
                            image: self.scannedImage,
                            recognitionResult: self.recognizer?.result)
                        self.frontDone = true
                        if self.frontOnly {
                            done = true
                        }
                    } else {
                        return
                    }
                } else {
                    if !self.frontOnly {
                        // Add as back
                        self.ivBack.image = self.scannedImage
                        self.delegate?.backPhotoTaken(
                            image: self.scannedImage,
                            recognitionResult: self.recognizer?.result)
                        self.backDone = true
                        if self.backOnly {
                            done = true
                        }
                    } else {
                        return
                    }
                }
                UIDevice.vibrate()
                recognizerRunner.resetState()

                if self.backDone && self.frontDone {
                    done = true
                }
                if done {
                    self.goBack()
                }
            }
            if let result = recognizer?.result {
                print(result)
            }

        case .empty:
            print("Scanned - empty")

        @unknown default:
            print("Unknown recognition state")
        }

        processing = false
    }

    private func isFront() -> Bool {
        let result = recognizer?.result
        let recognitionMode = result?.recognitionMode
        return recognitionMode == MBRecognitionMode(rawValue: 5)
    }
}

extension StaffPhotoDNIViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func getImageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(
            rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        guard let context = CGContext(
            data: baseAddress, width: width, height: height,
            bitsPerComponent: 8, bytesPerRow: bytesPerRow,
            space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }
        guard let cgImage = context.makeImage() else {
            return nil
        }
        let image = UIImage(cgImage: cgImage, scale: 1, orientation: .right)
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        return image
    }

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard !processing,
              let capturedImage = getImageFromSampleBuffer(sampleBuffer: sampleBuffer) else {
            return
        }

        processing = true

        DispatchQueue.global().async {
            let orientation = capturedImage.imageOrientation
            let image: UIImage
            if orientation != .up {
                image = capturedImage.rotate(radians: 0)! // img.rotate(radians: .pi / 2)!
            } else {
                image = capturedImage
            }
            let newWidth = image.size.width * 0.9
            let newHeight = newWidth * 5 / 8
            let marginHor = (image.size.width - newWidth) / 2
            let marginVert = (image.size.height - newHeight) / 2

            let boundingBox = CGRect(x: marginHor, y: marginVert, width: newWidth, height: newHeight)
            guard let cgImage = image.cgImage?.cropping(to: boundingBox) else {
                self.processPhoto(image: image)
                return
            }

            self.processPhoto(image: UIImage(cgImage: cgImage))
        }
    }
}
