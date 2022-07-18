//
//  DetailInformationViewController.swift
//  DemoMacOSXIB
//
//  Created by Duy Tran N. on 13/07/2022.
//

import Cocoa

final class DetailInformationViewController: NSViewController {

    @IBOutlet private weak var userTableView: NSTableView!
    @IBOutlet private weak var vehicleTableView: NSTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            AppDelegate.shared.changeRoot(to: .home)
        }
    }
}

// MARK: - Extension NSTableViewDataSource
extension DetailInformationViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        switch tableView {
        case userTableView:
            return 20
        case vehicleTableView:
            return 30
        default: return 0
        }
    }
}

// MARK: - Extension NSTableViewDelegate
extension DetailInformationViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        switch tableColumn?.identifier {
        case NSUserInterfaceItemIdentifier(rawValue: "userIdColumn"):
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "userIdCell")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.integerValue = row + 1
            return cellView
        case NSUserInterfaceItemIdentifier(rawValue: "userNameColumn"):
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "userNameCell")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.stringValue = "Bumios \(row)"
            return cellView
        case NSUserInterfaceItemIdentifier(rawValue: "userGenderColumn"):
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "userGenderCell")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.stringValue = row % 2 == 0 ? "Male" : "Female"
            return cellView
        case NSUserInterfaceItemIdentifier(rawValue: "vehicleNameColumn"):
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "vehicleNameCell")
            let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
            let randomString = String((0..<10).map{ _ in letters.randomElement()! })
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.stringValue = randomString
            return cellView
        case NSUserInterfaceItemIdentifier(rawValue: "vehiclePlateColumn"):
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "vehiclePlateCell")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.stringValue = UUID().uuidString
            return cellView
//        case NSUserInterfaceItemIdentifier(rawValue: "identityInfoColumn"):
//            let identityInfo = user.identityInfo
//            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "identityInfoCell")
//            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? IdentityInfoCellView else { return nil }
//            cellView.textField?.stringValue = identityInfo?.cardNumber ?? ""
//            cellView.dateLabel?.stringValue = (identityInfo?.date ?? Date()).toString
//            cellView.placeLabel?.stringValue = identityInfo?.place ?? ""
//            cellView.statusPopUpButton?.removeAllItems()
//            cellView.statusPopUpButton?.addItems(withTitles: IdentityInformation.CardStatus.allCases.map({ $0.rawValue }))
//            return cellView
        default:
            return nil
        }
    }

//    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
//        return 40
//    }
}
