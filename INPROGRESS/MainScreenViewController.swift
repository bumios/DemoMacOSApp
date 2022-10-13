//
//  MainScreenViewController.swift
//  AutoStreemLite
//
//  Created by Duy Tran N. on 12/10/2022.
//

import Cocoa

final class MainScreenViewController: NSViewController {

    @IBOutlet private weak var tableView: NSTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Scroll to first item when screen loaded
        tableView.scrollToBeginningOfDocument(self)
    }
}

extension MainScreenViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var itemView: NSTableCellView?

        if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "nameColumn") {
            guard let cellView = makeCellView(from: "nameCell") else { return nil }
            cellView.textField?.stringValue = "/Users/John.Doe/Desktop/AutoStream/Downstreem/15. Setting \(row)"
            itemView = cellView

            if #available(macOS 10.13, *) {
                itemView?.wantsLayer = true
                itemView?.layer?.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
                itemView?.layer?.cornerRadius = 4.0
            }
        } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "typeColumn") {
//            guard let cellView = makeCellView(from: "typeCell") else { return nil }
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "typeCell")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? TypeInfoCellView else { return nil }
            cellView.delegate = self

            var typeValue: String = ""
            if row % 2 == 0 {
                typeValue = "File"
            } else {
                typeValue = "PDF Document"
            }

            cellView.setTypeTitleText(typeValue)
//            cellView.textField?.stringValue = typeValue
            itemView = cellView

            if #available(macOS 10.13, *) {
                itemView?.wantsLayer = true
                itemView?.layer?.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
                itemView?.layer?.cornerRadius = 4.0
            }
        }

        if row % 2 == 0 {
            itemView?.layer?.backgroundColor = NSColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 0.5).cgColor
        } else {
            itemView?.layer?.backgroundColor = NSColor.white.cgColor
        }

        return itemView
    }

    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 48
    }
}

extension MainScreenViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 30
    }
}

extension MainScreenViewController: TypeInfoCellViewDelegate {
    func cell(_ cell: NSTableCellView, needPerform action: TypeInfoCellView.Action) {
        // TODO: - Continue detect row index
    }
}

// MARK: - Extension MainScreenViewController
extension MainScreenViewController {

    // MARK: Private functions
    private func makeCellView(from identifier: String) -> NSTableCellView? {
        let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: identifier)
        guard let view = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
        return view
    }
}

// MARK: - TypeInfoCellView
protocol TypeInfoCellViewDelegate: AnyObject {
    func cell(_ cell: NSTableCellView, needPerform action: TypeInfoCellView.Action)
}

final class TypeInfoCellView: NSTableCellView {

    // MARK: - Enumeration
    enum Action {
        case tappedTrashButton
    }

    // MARK: - IBOutlets
    @IBOutlet private weak var typeTextField: NSTextField?
    @IBOutlet private weak var trashButton: NSButton?

    // MARK: - Properties
    weak var delegate: TypeInfoCellViewDelegate?

    // MARK: - Public functions
    func setTypeTitleText(_ title: String) {
        typeTextField?.stringValue = title
    }

    @IBAction private func trashButtonTouchUpInside(_ button: NSButton) {
        delegate?.cell(self, needPerform: .tappedTrashButton)
    }
}
