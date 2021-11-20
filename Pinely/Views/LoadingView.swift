//
//  LoadingView.swift
//  Pinely
//

import UIKit
import SwiftyGif

class LoadingView: UIView {
    var ivAnimation: UIImageView!
    var lblText: UILabel!
    var ivPlanet: UIImageView?
    var lblPlanetText: UILabel?
    var attributes: [NSAttributedString.Key: Any] = [:]
    var viewController: ViewController?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        self.backgroundColor = UIColor.black

        let screenSize = UIScreen.main.bounds
        let imageSize = CGSize(width: 256, height: 256)

        do {
            let gifImage = try UIImage(gifName: "PineAnimation.gif")
            ivAnimation = UIImageView(gifImage: gifImage, loopCount: -1)
            ivAnimation.frame = CGRect(
                x: (screenSize.width - imageSize.width) / 2,
                y: (screenSize.height - imageSize.height) / 2 - 42,
                width: imageSize.width, height: imageSize.height)
            self.addSubview(ivAnimation)
        } catch {
            print(error)
        }

        let font = UIFont(name: "Montserrat-Semibold", size: 13)!
        lblText = UILabel(frame: CGRect(x: 50, y: (screenSize.height + imageSize.height) / 2 - 26, width: screenSize.width - 100, height: 80))
        lblText.font = font
        lblText.textColor = UIColor.white
        lblText.numberOfLines = 0
        lblText.textAlignment = .center

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 8
        paragraphStyle.alignment = .center
        attributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]

        self.addSubview(lblText)
    }

    func run(text: String) {
        lblText.attributedText = NSAttributedString(string: text, attributes: attributes)
        viewController?.loadingViewStarted()
        ivAnimation?.startAnimatingGif()
    }

    func stopAndRemove() {
        ivAnimation?.stopAnimatingGif()
        viewController?.loadingViewFinished()
        self.removeFromSuperview()
    }

    func addPlanet() {
        let screenSize = UIScreen.main.bounds
        var bottomPadding = CGFloat(12)
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            bottomPadding += window?.safeAreaInsets.bottom ?? 0
        }
        let font = AppFont.regular[12]
        let fontSemibold = AppFont.semiBold[12]
        lblPlanetText = UILabel(frame: CGRect(x: 50, y: screenSize.height - 50 - bottomPadding, width: screenSize.width - 100, height: 50))
        lblPlanetText!.font = font
        lblPlanetText!.textColor = UIColor.white
        lblPlanetText!.numberOfLines = 0
        lblPlanetText!.textAlignment = .center
        lblPlanetText!.minimumScaleFactor = 0.5
        let text = NSMutableAttributedString(string: "Donaremos el ", attributes: [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.white
        ])
        text.append(NSAttributedString(string: "0,50% de tu compra ", attributes: [
            NSAttributedString.Key.font: fontSemibold,
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]))
        text.append(NSAttributedString(string: "para financiar sistemas de eliminación de emisiones de CO₂ en la atmósfera.", attributes: [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]))
        lblPlanetText!.attributedText = text
        self.addSubview(lblPlanetText!)

        bottomPadding += 60

        ivPlanet = UIImageView(frame: CGRect(x: (screenSize.width - 40) / 2, y: screenSize.height - 40 - bottomPadding, width: 40, height: 40))
        ivPlanet!.contentMode = .scaleAspectFit
        ivPlanet!.image = #imageLiteral(resourceName: "PlanetEarth")
        self.addSubview(ivPlanet!)
    }

    static func showAndRun(text: String, viewController: ViewController? = nil) -> LoadingView? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        guard let window = appDelegate.window else { return nil }

        let loadingView = LoadingView(frame: UIScreen.main.bounds)
        loadingView.viewController = viewController
        loadingView.run(text: text)
        window.addSubview(loadingView)

        return loadingView
    }
}
