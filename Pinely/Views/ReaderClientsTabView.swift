//
//  ReaderClientsTabView.swift
//  Pinely
//

import UIKit

protocol ReaderClientsTabViewDelegate: CellTicketSaleDelegate {
    func refreshClients(delegate: @escaping () -> Void)
}

class ReaderClientsTabView: UIView {
    @IBOutlet var contentView: UIView!

    @IBOutlet weak var cvClients: UICollectionView!

    @IBOutlet weak var vAllScanned: UIView!
    @IBOutlet weak var lblAllScannedTitle: UILabel!
    @IBOutlet weak var lblAllScannedText: UILabel!

    private let refreshControl = UIRefreshControl()

    var sales: [QRSale] = []
    weak var delegate: ReaderClientsTabViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        let nibName = "ReaderClientsTabView"
        Bundle.main.loadNibNamed(nibName, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        cvClients.register(UINib(nibName: "CellTicketSale", bundle: nil), forCellWithReuseIdentifier: "TicketSale")

        cvClients.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshClients), for: .valueChanged)
    }

    func prepare(tabIndex: Int, sales: [QRSale], delegate: ReaderClientsTabViewDelegate?) {
        switch tabIndex {
        case 0:
            self.sales = sales
            lblAllScannedTitle.text = "¡Nada por aquí!"
            lblAllScannedText.text = "No se han vendido entradas para este evento aun"

        case 1:
            self.sales = sales.filter { $0.status == .notValidated }.sorted(by: { ($0.id ?? 0) > ($1.id ?? 0) })
            lblAllScannedTitle.text = "¡Eres increíble!"
            lblAllScannedText.text = "No hay mas entradas por validar, ahora toca celebrar"

        case 2:
            self.sales = sales.filter { $0.status == .validated }
            lblAllScannedTitle.text = "¡Nada por aquí!"
            lblAllScannedText.text = "Todavía no se han validado entradas"

        case 3:
            self.sales = sales.filter { $0.status == .rejected }
            lblAllScannedTitle.text = "¡Todo en orden!"
            lblAllScannedText.text = "No se han rechazado entradas en este evento"

        case 4:
            self.sales = sales.filter { $0.status == .mixed }
            lblAllScannedTitle.text = "¡Todo en orden!"
            lblAllScannedText.text = "No se han rechazado entradas en este evento"

        default: self.sales = []
        }

        self.delegate = delegate

        vAllScanned.isHidden = !sales.isEmpty
        cvClients.isHidden = sales.isEmpty

        cvClients.reloadData()
    }

    @objc func refreshClients() {
        AppSound.uiRefreshFeed.play()
        if let delegate = self.delegate {
            delegate.refreshClients {
                self.refreshControl.endRefreshing()
            }
        } else {
            self.refreshControl.endRefreshing()
        }
    }
}

extension ReaderClientsTabView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sales.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TicketSale", for: indexPath) as? CellTicketSale
        cell?.prepare(sale: sales[indexPath.item], delegate: delegate)
        return cell ?? UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: UIScreen.main.bounds.width - 40, height: 90)
    }
}

extension ReaderClientsTabView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        cvClients.visibleCells.forEach {
            ($0 as? CellTicketSale)?.massCancelClick()
        }
    }
}
