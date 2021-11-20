//
//  ArticleViewController.swift
//  Pinely
//

import UIKit

class ArticleViewController: ViewController {
    @IBOutlet weak var cvTags: UICollectionView!
    @IBOutlet weak var ivPicture: UIImageView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblDescription: UILabel!

    var place: Place!

    @IBAction func share() {

    }
}

extension ArticleViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        place.tags.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Tag", for: indexPath) as? CellTag
        cell?.prepare(tagTitle: place.tags[indexPath.item], tagIndex: indexPath.item)
        return cell ?? UICollectionViewCell()
    }
}
