//
//  MyPaymentMethodsViewController.swift
//  Pinely
//

import UIKit
import FirebaseAuth
import SwiftEventBus

protocol PaymentMethodSelectionDelegate: AnyObject {
    func paymentMethodSelected(_ paymentMethod: Card)
}

class MyPaymentMethodsViewController: ViewController {
    @IBOutlet weak var cvPaymentMethods: UICollectionView!
    @IBOutlet weak var aiLoading: UIActivityIndicatorView!

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblButton: UILabel!

    weak var delegate: PaymentMethodSelectionDelegate?
    var cards: [Card] = []

    var slideRecognizer = UISwipeGestureRecognizer()

    override func viewDidLoad() {
        super.viewDidLoad()

        if cards.isEmpty {
            loadPaymentMethods()
        } else {
            self.aiLoading.stopAnimating()
        }

        if navigationController == nil {
            slideRecognizer.addTarget(self, action: #selector(slidedBack))
            slideRecognizer.direction = .right
            cvPaymentMethods.addGestureRecognizer(slideRecognizer)
        }

        SwiftEventBus.onMainThread(self, name: "paymentMethodsUpdated") { (_) in
            self.loadPaymentMethods()
        }

        if let translation = AppDelegate.translation {
            lblTitle.text = translation.getString("profile_payment_methods") ?? lblTitle.text

            lblButton.text = translation.getString("add_new_credit_card") ?? lblButton.text
        }

    }

    deinit {
        SwiftEventBus.unregister(self, name: "authChanged")
    }

    @objc func slidedBack() {
        self.goBack()
    }

    private func loadPaymentMethods() {
        API.shared.getPaymentMethods(delegate: { (cards, error) in
            self.aiLoading.stopAnimating()
            if let error = error {
                self.show(error: error) {
                    self.goBack()
                }
                return
            }

            self.cards = cards
            self.cvPaymentMethods.reloadData()
        })
    }

    @IBAction func addNewCard() {
        UIDevice.vibrate()
        // Check if user information is ready
        API.shared.loadUserInfo(force: false) { (profile, error) in
            if let error = error {
                self.show(error: error)
                return
            }

            let mobilePhone = profile?.mobilePhone ?? ""
            if mobilePhone.isEmpty {
                // Finish registration
                SwiftEventBus.onMainThread(self, name: "authChanged") { (_) in
                    SwiftEventBus.unregister(self, name: "authChanged")

                    if Auth.auth().currentUser != nil {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.addNewCard()
                        }
                    }
                }
                self.performSegue(withIdentifier: "FinishRegistration", sender: self)
                return
            }

            let addCardStoryboard = UIStoryboard(name: "AddCard", bundle: nil)
            guard let initialVC = addCardStoryboard.instantiateInitialViewController() else {
                return
            }
            initialVC.modalPresentationStyle = .fullScreen
            self.present(initialVC, animated: true, completion: nil)
        }
    }

}

extension MyPaymentMethodsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cards.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Card", for: indexPath) as? CellCard
        cell?.backgroundColor = .clear
        cell?.prepare(card: cards[indexPath.row], isLast: indexPath.row >= cards.count - 1)
        return cell ?? UICollectionViewCell()
    }

    fileprivate func selectedApplePay() {
        // Apple Pay
        let translation = AppDelegate.translation
        let strTitle = translation?.getString("apple_pay_method_title") ?? "Apple Pay"
        let strDescription = translation?.getString("apple_pay_method_description") ??
            "Este es el método de pago nativo de tu dispositivo. No se puede eliminar"
        let strOK = translation?.getString("apple_pay_method_cancel") ?? "Aceptar"

        let alert = UIAlertController(title: strTitle, message: strDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: strOK, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    fileprivate func selectedPaypal() {
        // Paypal
        let translation = AppDelegate.translation
        let strTitle = translation?.getString("soon_payment_method_title") ?? "Coming Soon"
        let strDescription = translation?.getString("soon_payment_method_description") ?? ""
        let strOK = translation?.getString("soon_payment_method_button") ?? "Aceptar"
        let alert = UIAlertController(title: strTitle, message: strDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: strOK, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
        
    fileprivate func selectedBitcoin() {
        // Bitcoin
        let translation = AppDelegate.translation
        let strTitle = translation?.getString("soon_payment_method_title2") ?? "Coming Soon"
        let strDescription = translation?.getString("soon_payment_method_description2") ?? ""
        let strOK = translation?.getString("soon_payment_method_button2") ?? "Aceptar"
        let alert = UIAlertController(title: strTitle, message: strDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: strOK, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

        

    private func performConfirmedCardDeletion(_ profile: Profile?, _ paymentMethod: String, _ loading: BlurryLoadingView) {
        API.shared.deleteCard(cusIdStripe: profile?.cusIdStripe ?? "",
                              paymentMethod: paymentMethod) { (error) in
            if let error = error {
                loading.stopAndHide()
                self.show(error: error)
                return
            }

            API.shared.getPaymentMethods(delegate: { (cards, _) in
                loading.stopAndHide()
                self.cards = cards
                self.cvPaymentMethods.reloadData()
            })
        }
    }

    private func selectedCreditCard(_ card: Card) {
        // Credit Card
        var strTitle: String?
        var strDescription: String?
        var strCancel: String?
        var  strDelete: String?

        if let translation = AppDelegate.translation {

            strTitle = translation.getString("delete_credit_card_title") ?? "¿Eliminar método de pago?"

            strDescription = translation.getString("delete_credit_card_description") ?? "Recuerda que ya no podrás hacer compras con esta tarjeta"

            strCancel = translation.getString("delete_credit_card_cancel") ?? "Cancelar"
            strDelete = translation.getString("delete_credit_card_agree") ?? "Eliminar"
        } else {
            strTitle = "¿Eliminar método de pago?"
            strDescription =  "Recuerda que ya no podrás hacer compras con esta tarjeta"
            strCancel =  "Cancelar"
            strDelete =  "Eliminar"
        }

        let alert = UIAlertController(title: strTitle, message: strDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: strDelete, style: .destructive) { (_) in
            let loading = BlurryLoadingView.showAndStart()
            API.shared.loadUserInfo(force: false) { (profile, error) in
                if let error = error {
                    loading.stopAndHide()
                    self.show(error: error)
                    return
                }

                guard let paymentMethod = card.paymentMethod else {
                    loading.stopAndHide()
                    self.showError("No se puede eliminar")
                    return
                }

                self.performConfirmedCardDeletion(profile, paymentMethod, loading)
            }

        })
        alert.addAction(UIAlertAction(title: strCancel, style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        if indexPath.row < cards.count {
            if let delegate = delegate {
                delegate.paymentMethodSelected(cards[indexPath.item])
                self.goBack()
            } else {
                let card = cards[indexPath.item]
                if let cardType = card.type {
                    switch cardType {
                    case .apple:
                        selectedApplePay()

                    case .paypal:
                        selectedPaypal()
                        
                    case .bitcoin:
                        selectedBitcoin()

                    default:
                        selectedCreditCard(card)
                    }
                }
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: UIScreen.main.bounds.width - 28 * 2, height: 63)
    }
}
