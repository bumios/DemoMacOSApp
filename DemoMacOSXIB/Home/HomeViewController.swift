//
//  HomeViewController.swift
//  DemoMacOSXIB
//
//  Created by Duy Tran N. on 24/05/2022.
//

import Cocoa

final class HomeViewController: NSViewController {

    @IBOutlet private weak var inputTextField: NSTextField!
    @IBOutlet private weak var submitButton: NSButton!
    @IBOutlet private weak var tableView: NSTableView!
    @IBOutlet private weak var dragView: DragView!

    let viewModel = HomeViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        dragView.delegate = self
    }

    @IBAction func submitButtonTapped(_ sender: Any) {
        if inputTextField.stringValue.isEmpty {
//            titleLabel.stringValue = "Please input on text box above"
        } else {
//            titleLabel.stringValue = inputTextField.stringValue
        }
    }
}

extension HomeViewController: DragViewDelegate {
    func dragViewDidReceive(fileURLs: [URL]) {
        print("-----", fileURLs)
    }
}

extension HomeViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return viewModel.numberOfRows()
    }
}

extension HomeViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let user = viewModel.getUser(at: row)

        switch tableColumn?.identifier {
        case NSUserInterfaceItemIdentifier(rawValue: "idColumn"):
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "idCell")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.integerValue = row + 1
            return cellView
        case NSUserInterfaceItemIdentifier(rawValue: "nameColumn"):
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "nameCell")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.stringValue = user.name ?? ""
            return cellView
        case NSUserInterfaceItemIdentifier(rawValue: "ageColumn"):
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "ageCell")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.integerValue = user.age ?? 0
            return cellView
        case NSUserInterfaceItemIdentifier(rawValue: "genderColumn"):
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "genderCell")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            cellView.imageView?.image = user.gender?.iconImage
            cellView.imageView?.contentTintColor = user.gender?.iconTintColor
            cellView.textField?.stringValue = user.gender?.displayValue ?? ""
            return cellView
        case NSUserInterfaceItemIdentifier(rawValue: "identityInfoColumn"):
            let identityInfo = user.identityInfo
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "identityInfoCell")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? IdentityInfoCellView else { return nil }
            cellView.textField?.stringValue = identityInfo?.cardNumber ?? ""
            cellView.dateLabel?.stringValue = (identityInfo?.date ?? Date()).toString
            cellView.placeLabel?.stringValue = identityInfo?.place ?? ""
            cellView.statusPopUpButton?.removeAllItems()
            cellView.statusPopUpButton?.addItems(withTitles: IdentityInformation.CardStatus.allCases.map({ $0.rawValue }))
            return cellView
        default:
            return nil
        }
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 40
    }
}

class IdentityInfoCellView: NSTableCellView {
    @IBOutlet weak var dateLabel: NSTextField?
    @IBOutlet weak var placeLabel: NSTextField?
    @IBOutlet weak var statusPopUpButton: NSPopUpButton?
}

extension Date {
    var toString: String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/YYYY"
        return dateFormatter.string(from: date)
    }
}
