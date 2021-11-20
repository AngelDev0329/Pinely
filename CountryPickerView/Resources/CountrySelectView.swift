//
//  CountrySelectView.swift
//  terncommerce
//
//  Created by 朱慧平 on 2018/1/30.
//  Copyright © 2018年 terncommerce. All rights reserved.
//

import UIKit

public enum DisplayLanguageType {
    case chinese
    case english
    case spanish
}
open class CountrySelectView: UIView {
    public static let shared = CountrySelectView()
    public var selectedCountryCallBack : ((_ countryDic: [String: Any]) -> Void)!
    fileprivate var countryTableView = UITableView()
    public var searchCountrys: [[String: Any]]!
    fileprivate var searchBarView = UISearchBar()
    fileprivate var regex = ""

    public var searchBarPlaceholder: String = "search" {
        didSet {
            searchBarView.placeholder = searchBarPlaceholder
        }
    }
    public var countryNameFont: UIFont = UIFont.systemFont(ofSize: 16) {
        didSet {
            countryTableView.reloadData()
        }
    }
    public var countryPhoneCodeFont: UIFont = UIFont.systemFont(ofSize: 14) {
        didSet {
            countryTableView.reloadData()
        }
    }
    public var countryNameColor: UIColor = .black {
        didSet {
            countryTableView.reloadData()
        }
    }
    public var countryPhoneCodeColor: UIColor = .gray {
        didSet {
            countryTableView.reloadData()
        }
    }
    public var barTintColor: UIColor = .green {
        didSet {
            searchBarView.tintColor = barTintColor
        }
    }
    public var displayLanguage: DisplayLanguageType = .english {
        didSet {
            countryTableView.reloadData()
        }
    }

    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        searchCountrys = countryCodeJson
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(self.dismiss))
        tap.delegate = self
        self.addGestureRecognizer(tap)
        self.backgroundColor = UIColor.init(white: 0, alpha: 0.6)
        self.addSubview(countryTableView)
        countryTableView.register(CountryTableViewCell.classForCoder(), forCellReuseIdentifier: "CountryTableViewCell")
        countryTableView.delegate = self
        countryTableView.dataSource = self
        countryTableView.separatorStyle = .none
        countryTableView.backgroundColor = .clear

        searchBarView.placeholder = "search"
        searchBarView.backgroundColor = .white
        searchBarView.backgroundImage = UIImage(named: "")
        searchBarView.barTintColor = .white
        searchBarView.tintColor = UIColor.green
        searchBarView.showsCancelButton = false
        searchBarView.delegate = self
        searchBarView.frame = CGRect(x: 0, y: 0, width: 0.8*self.frame.size.width, height: 44)
        countryTableView.tableHeaderView = searchBarView
        countryTableView.layer.masksToBounds = true
        countryTableView.layer.cornerRadius = 5.0

    }
    func setLayout() {

        self.translatesAutoresizingMaskIntoConstraints = false
        countryTableView.translatesAutoresizingMaskIntoConstraints = false
        self.superview!.addConstraint(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: self.superview!, attribute: .width, multiplier: 1.0, constant: 0.0))
        self.superview!.addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: self.superview!, attribute: .height, multiplier: 1.0, constant: 0.0))
        self.superview!.addConstraint(NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: self.superview!, attribute: .centerX, multiplier: 1.0, constant: 0))
        self.superview!.addConstraint(NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: self.superview!, attribute: .centerY, multiplier: 1.0, constant: 0))

        self.addConstraint(NSLayoutConstraint(item: countryTableView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.8, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: countryTableView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.7, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: countryTableView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: countryTableView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))

    }
    public func show() {

        if let window = UIApplication.shared.delegate!.window! {
            window.addSubview(self)
        }
        searchBarView.text = ""
        searchCountrys = countryCodeJson
        self.countryTableView.reloadData()
        self.setLayout()
    }
    @objc public func dismiss() {
        self.removeFromSuperview()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
private typealias searchBarDelegate = CountrySelectView
extension searchBarDelegate: UISearchBarDelegate {
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {
            searchCountrys = countryCodeJson
            countryTableView.reloadData()
            return
        }

        self.getRegexString(searchString: searchText.lowercased())
        var results: [[String: Any]] = []
        for countryDic in countryCodeJson {
            let zh = countryDic["zh"] as! String
            let en = countryDic["en"] as! String
            let es = countryDic["es"] as! String
            let code = "\(countryDic["code"] as! NSNumber)"
            let locale = countryDic["locale"] as! String
            if self.checkSearchStringCharHas(compareString: zh.lowercased())||self.checkSearchStringCharHas(compareString: en.lowercased().replacingOccurrences(of: " ", with: ""))||self.checkSearchStringCharHas(compareString: es.lowercased().replacingOccurrences(of: " ", with: ""))||self.checkSearchStringCharHas(compareString: code)||self.checkSearchStringCharHas(compareString: locale.lowercased().replacingOccurrences(of: " ", with: "")) {
                results.append(countryDic)
            }
        }
        searchCountrys = results
        countryTableView.reloadData()
    }
    func getRegexString(searchString: String) {
        var str: String = ""
        let count = searchString.count
        for index in 0..<count {
            let i = searchString.index(searchString.startIndex, offsetBy: index, limitedBy: searchString.endIndex)
            if str.count == 0 {
                str = "(^|[a-z0-9\\u4e00-\\u9fa5])+[\(searchString[i!])]"
            } else {
                str = "\(str)+[a-z0-9\\u4e00-\\u9fa5]*[\(searchString[i!])]"
            }
            print(searchString[i!])
        }
        regex = "\(str)+[a-z0-9\\u4e00-\\u9fa5]*$"
    }
    func checkSearchStringCharHas(compareString: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let isValid = predicate.evaluate(with: compareString)
        return isValid
    }

}
private typealias tapGestureDelegate = CountrySelectView
extension tapGestureDelegate: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {

        if NSStringFromClass((touch.view?.classForCoder)!).components(separatedBy: ".").last! == "UITableViewCellContentView"{
            return false
        }
        return true
    }
}
private typealias tableViewDelegate = CountrySelectView
extension tableViewDelegate: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var dic = searchCountrys[indexPath.row]
        dic["countryImage"] = UIImage(named: "CountryPicker.bundle/\(searchCountrys[indexPath.row]["locale"] as! String)")
        self.selectedCountryCallBack(dic)
        self.dismiss()
    }
}
private typealias tableViewDataSource = CountrySelectView
extension tableViewDataSource: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchCountrys.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let indentifier = "CountryTableViewCell"

        var countryCell: CountryTableViewCell! = tableView.dequeueReusableCell(withIdentifier: indentifier) as? CountryTableViewCell

        if countryCell == nil {

            countryCell=CountryTableViewCell(style: .default, reuseIdentifier: indentifier)
        }
        if displayLanguage == .english {
            countryCell.countryNameLabel.text = (searchCountrys[indexPath.row]["en"] as! String)
        }
        if displayLanguage == .chinese {
            countryCell.countryNameLabel.text = (searchCountrys[indexPath.row]["zh"] as! String)
        }
        if displayLanguage == .spanish {
            countryCell.countryNameLabel.text = (searchCountrys[indexPath.row]["es"] as! String)
        }
        countryCell.countryNameLabel.font = countryNameFont
        countryCell.countryNameLabel.textColor = countryNameColor
        let path = Bundle(for: CountrySelectView.self).resourcePath! + "/CountryPicker.bundle"
        let caBundle = Bundle(path: path)!
        countryCell.countryImageView.image = UIImage(named: "\(searchCountrys[indexPath.row]["locale"] as! String)", in: caBundle, compatibleWith: nil)

        countryCell.phoneCodeLabel.text = "+\(searchCountrys[indexPath.row]["code"] as! NSNumber)"
        countryCell.phoneCodeLabel.font = countryPhoneCodeFont
        countryCell.phoneCodeLabel.textColor = countryPhoneCodeColor
        return countryCell
    }
}
