//
//  StaffEmployeesViewController.swift
//  Pinely
//

import UIKit

class StaffEmployeesViewController: ViewController {
    @IBOutlet weak var cvStatuses: UICollectionView!
    @IBOutlet weak var cvEmployees: UICollectionView!
    @IBOutlet weak var aiLoading: UIActivityIndicatorView!

    var employees: [Employee] = []
    var employeesFiltered: [Employee] = []
    var selectedTabIdx = 0

    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        cvEmployees.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshClients(_:)), for: .valueChanged)

        loadData()
    }

    private func loadData(
        delegate: @escaping () -> Void = {
            // Default empty delegate
        }
    ) {
        API.shared.getEmployeeList { (employees, error) in
            if let error = error {
                self.show(error: error)
                return
            }

            self.employees = employees
            self.aiLoading.stopAnimating()
            self.cvStatuses.reloadData()
            self.filter()
            delegate()
        }
    }

    @objc private func refreshClients(_ sender: Any) {
        DispatchQueue.main.async {
            AppSound.uiRefreshFeed.play()
            self.loadData {
                self.refreshControl.endRefreshing()
            }
        }
    }

    func filter(request: String? = nil) {
        switch selectedTabIdx {
        case 0: self.employeesFiltered = self.employees
        case 1: self.employeesFiltered = self.employees.filter { $0.range == "reader" }
        case 2: self.employeesFiltered = self.employees.filter { $0.range == "revisor" }
        case 3: self.employeesFiltered = self.employees.filter { $0.range == "staff" || $0.range == "sub-staff" }
        default: self.employeesFiltered = []
        }
        if let request = request,
            !request.isEmpty {
            let requestLc = request.lowercased().folding(options: .diacriticInsensitive, locale: .current)
            self.employeesFiltered = employeesFiltered
                .filter { $0.name?.lowercased()
                    .folding(options: .diacriticInsensitive, locale: .current)
                    .contains(requestLc) == true ||
                    $0.lastname?.lowercased()
                    .folding(options: .diacriticInsensitive, locale: .current)
                    .contains(requestLc) == true
                }
        }
        cvEmployees.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let staffEditEmployeeVC = segue.destination as? StaffEditEmployeeViewController,
           let employee = sender as? Employee {
            staffEditEmployeeVC.employee = employee
        }
    }
}

extension StaffEmployeesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case cvStatuses:
            return 4

        case cvEmployees:
            return employeesFiltered.count + 1

        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case cvStatuses:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Range", for: indexPath) as? CellRange
            let count: Int
            switch indexPath.item {
            case 0: count = employees.count
            case 1: count = employees.filter { $0.range == "reader" }.count
            case 2: count = employees.filter { $0.range == "revisor" }.count
            case 3: count = employees.filter { $0.range == "staff" }.count
            default: count = 0
            }
            cell?.prepare(statusIdx: indexPath.item, count: count, isSelected: selectedTabIdx == indexPath.item)
            return cell ?? UICollectionViewCell()

        case cvEmployees:
            if indexPath.item == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddEmployee", for: indexPath) as? CellAddEmployee
                cell?.prepare(delegate: self)
                return cell ?? UICollectionViewCell()
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Employee", for: indexPath) as? CellEmployee
                cell?.prepare(employee: employeesFiltered[indexPath.item - 1], delegate: self)
                return cell ?? UICollectionViewCell()
            }

        default:
            return UICollectionViewCell()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        switch collectionView {
        case cvStatuses:
            selectedTabIdx = indexPath.item

            filter()

            let contentOffset = cvStatuses.contentOffset

            cvStatuses.reloadData()
            cvStatuses.layoutIfNeeded()

            DispatchQueue.main.async { [weak self] in
                self?.cvStatuses.setContentOffset(contentOffset, animated: false)
            }

        case cvEmployees:
            break

        default:
            break
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case cvStatuses:
            let count: Int
            switch indexPath.item {
            case 0: count = employees.count
            case 1: count = employees.filter { $0.range == "reader" }.count
            case 2: count = employees.filter { $0.range == "revisor" }.count
            case 3: count = employees.filter { $0.range == "staff" }.count
            default: count = 0
            }
            let status = CellRange.ranges[indexPath.item] + " (\(count))"
            let font = AppFont.semiBold[10]
            return CGSize(width: status.width(withConstrainedHeight: 100, font: font) + 50, height: 40)

        case cvEmployees:
            return CGSize(width: UIScreen.main.bounds.width - 40, height: 90)

        default:
            return CGSize()
        }
    }

}

extension StaffEmployeesViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIDevice.vibrate()
        hideSearchBarPlaceholder()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text ?? "").isEmpty {
            showSearchBarPlaceholder()
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
           let textRange = Range(range, in: text) {
           let updatedText = text.replacingCharacters(in: textRange, with: string)
            self.filter(request: updatedText)
        }
        return true
    }
}

extension StaffEmployeesViewController: CellEmployeeDelegate, CellAddEmployeeDelegate {
    func employeeSelected(employee: Employee) {
        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.performSegue(withIdentifier: "StaffEditEmployee", sender: employee)
        }
    }

    func addEmployee() {
        UIDevice.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.performSegue(withIdentifier: "StaffCreateNewEmployee", sender: nil)
        }
    }
}

extension StaffEmployeesViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == cvEmployees {
            cvEmployees.visibleCells.forEach {
                ($0 as? CellEmployee)?.massCancelClick()
                ($0 as? CellAddEmployee)?.massCancelClick()
            }
        }
    }
}
