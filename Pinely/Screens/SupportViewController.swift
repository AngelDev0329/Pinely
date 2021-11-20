//
//  SupportViewController.swift
//  Pinely
//

import UIKit

enum SupportType: Equatable {
    case simple
    case refund
    case invoice
    case popup(shake: Bool, titleText: String?, descriptionText: String?, inputText: String?, buttonText: String?)
}

struct SupportQuestion {
    var title: String
    var descr: String
    var type: SupportType
}

class SupportViewController: ViewController {
    @IBOutlet weak var tvQuestions: UITableView!
    @IBOutlet weak var lblTitle: UILabel!

    var sale: Sale?

    var questions: [SupportQuestion] = [ ]

    fileprivate func buildQuestionList(_ options: [Any]) {
        questions = []
        for option in options {
            guard let optionDict = option as? [String: Any] else {
                continue
            }

            let title = optionDict.getString("title") ?? ""
            let typeScreen = optionDict.getString("type_screen") ?? ""
            let descr = optionDict.getString("description") ?? ""

            let supportType: SupportType
            switch typeScreen {
            case "only_text":
                supportType = .simple

            case "refund":
                supportType = .refund

            case "preview_invoice":
                supportType = .invoice

            case "support_request":
                let shake = optionDict.getBoolean("shake_to_support_pop_up") ?? false
                if shake {
                    supportType = .popup(
                        shake: shake,
                        titleText: optionDict.getString("shake_to_support_title_text"),
                        descriptionText: nil,
                        inputText: nil,
                        buttonText: optionDict.getString("shake_to_support_button_text")
                    )
                } else {
                    supportType = .popup(
                        shake: shake,
                        titleText: optionDict.getString("support_screen_title"),
                        descriptionText: optionDict.getString("support_screen_description"),
                        inputText: optionDict.getString("support_screen_input_text"),
                        buttonText: optionDict.getString("button_text")
                    )
                }

            default:
                continue
            }

            questions.append(SupportQuestion(title: title, descr: descr, type: supportType))
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let remoteConfig = (UIApplication.shared.delegate as? AppDelegate)?.remoteConfig,
           let support = remoteConfig.configValue(forKey: "support").jsonValue as? [String: Any] {
            if let titleScreen = support.getString("title_screen") {
                self.lblTitle.text = titleScreen
            }
            if let options = support["options"] as? [Any] {
                buildQuestionList(options)
                tvQuestions.reloadData()
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let supportAnswerVC = segue.destination as? SupportAnswerViewController,
            let question = sender as? SupportQuestion {
            supportAnswerVC.question = question
        } else if let supportInvoiceVC = segue.destination as? SupportInvoiceViewController,
                  let question = sender as? SupportQuestion {
            supportInvoiceVC.question = question
            supportInvoiceVC.sale = sale
            supportInvoiceVC.delegate = self
        } else if let supportRequestVC = segue.destination as? SupportRequestViewController,
                  let args = sender as? (String?, String?, String?, String?) {
            supportRequestVC.screenTitle = args.0
            supportRequestVC.screenDescription = args.1
            supportRequestVC.inputText = args.2
            supportRequestVC.buttonText = args.3
        }
    }
}

extension SupportViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        questions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Question", for: indexPath)
        if let label = cell.viewWithTag(1) as? UILabel {
            label.text = questions[indexPath.row].title
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch questions[indexPath.row].type {
        case .simple, .refund:
            performSegue(withIdentifier: "SupportAnswer", sender: questions[indexPath.row])

        case .invoice:
            performSegue(withIdentifier: "SupportInvoice", sender: questions[indexPath.row])

        case .popup(let shake, let titleText, let descriptionText, let inputText, let buttonText):
            if shake {
                let alert = UIAlertController(
                    title: nil,
                    message: titleText ?? questions[indexPath.row].descr,
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: buttonText ?? "Cancelar", style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
            } else {
                performSegue(withIdentifier: "SupportRequest",
                             sender: (titleText, descriptionText, inputText, buttonText))
            }
        }

    }
}

extension SupportViewController: SupportInvoiceViewControllerDelegate {
    func invoiceSent() {
        self.goBack()
    }
}
