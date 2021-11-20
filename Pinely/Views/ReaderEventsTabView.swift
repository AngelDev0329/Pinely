//
//  ReaderEventsTabView.swift
//  Pinely
//

import UIKit

class ReaderEventsTabView: UIView {
    @IBOutlet var contentView: UIView!

    @IBOutlet weak var cvEvents: UICollectionView!

    var events: [Event] = []
    weak var delegate: CellEventDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        let nibName = "ReaderEventsTabView"
        Bundle.main.loadNibNamed(nibName, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        cvEvents.register(UINib(nibName: "CellEvent", bundle: nil), forCellWithReuseIdentifier: "Event")
    }

    func prepare(events: [Event], delegate: CellEventDelegate) {
        self.events = events
        self.delegate = delegate

        cvEvents.reloadData()
    }
}

extension ReaderEventsTabView: UICollectionViewDelegate,
                               UICollectionViewDataSource,
                               UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        events.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Event", for: indexPath) as? CellEvent
        let event = events[indexPath.row]
        cell?.prepare(event: event, delegate: delegate)
        return cell ?? UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = UIScreen.main.bounds.width - 40
        let picWidth = cellWidth - 16
        let picHeight = picWidth * 145 / 368
        let cellHeight = picHeight + 16
        return CGSize(width: cellWidth, height: cellHeight)
    }
}
