//
//  SupportAnswerViewController.swift
//  Pinely
//

import UIKit
import WebKit

class SupportAnswerViewController: ViewController {
    @IBOutlet weak var lblQuestion: UILabel!
    @IBOutlet weak var wkAnswer: WKWebView!
    @IBOutlet weak var vRefund: UIView!

    var question: SupportQuestion?
    var refundAllowed: Bool = false

    // swiftlint:disable function_body_length
    func createStyle(backgroundHex: String, foregroundHex: String) -> String {
        """
@font-face
{
font-family: 'Montserrat';
font-weight: normal;
src: url(Montserrat-Regular.ttf);
}
@font-face
{
font-family: 'Montserrat';
font-weight: bold;
src: url(Montserrat-Bold.ttf);
}
@font-face
{
font-family: 'Montserrat';
font-weight: 800;
src: url(Montserrat-ExtraBold.ttf);
}
@font-face
{
font-family: 'Montserrat';
font-weight: 900;
src: url(Montserrat-ExtraBold.ttf);
}
@font-face
{
font-family: 'Montserrat';
font-weight: 200;
src: url(Montserrat-Light.ttf);
}
@font-face
{
font-family: 'Montserrat';
font-weight: 300;
src: url(Montserrat-Light.ttf);
}
@font-face
{
font-family: 'Montserrat';
font-weight: 500;
src: url(Montserrat-Medium.ttf);
}
@font-face
{
font-family: 'Montserrat';
font-weight: 600;
src: url(Montserrat-SemiBold.ttf);
}

body {
font-family: 'Montserrat';
font-size: 10pt;
padding: 0px;
margin: 0px;
background-color: \(backgroundHex);
color: \(foregroundHex);
text-color: \(foregroundHex);
}
"""
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        vRefund.isHidden = question?.type != SupportType.refund

        let backgroundHex = (UIColor(named: "MainBackgroundColor") ?? .white).hex
        let foregroundHex = (UIColor(named: "MainForegroundColor") ?? .black).hex
        let style = createStyle(backgroundHex: backgroundHex, foregroundHex: foregroundHex)

        let qDescr = (question?.descr ?? "")
        lblQuestion.text = question?.title ?? ""
        // swiftlint:disable line_length
        let html = "<html><head><title>" + qDescr +
            "</title><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'><style>" + style +
            "</style></head><body style=\"font-family: Montserrat; font-weight: normal; font-size: 10pt;\">" + qDescr +
            "<p><br /></p><p><br /></p><p><br /></p><p><br /></p><p><br /></p><p><br /></p></body></html>"
        wkAnswer.loadHTMLString(html, baseURL: Bundle.main.resourceURL)
    }

    @IBAction func claimRefund() {

    }
}
