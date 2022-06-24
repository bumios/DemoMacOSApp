//
//  HomeViewController.swift
//  DemoMacOSXIB
//
//  Created by Duy Tran N. on 24/05/2022.
//

import Cocoa
import NMSSH

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
        testUploadFilesToFTP()
    }

    var alert: NSAlert?

    @IBAction func submitButtonTapped(_ sender: Any) {
//        if inputTextField.stringValue.isEmpty {
////            titleLabel.stringValue = "Please input on text box above"
//        } else {
////            titleLabel.stringValue = inputTextField.stringValue
//        }

        // MARK: - Show custom alert
//        let vc = CustomAlertViewController()
//        let anotherWindow = NSWindow(contentViewController: vc)
//        anotherWindow.makeKeyAndOrderFront(self)

        // MARK: - Show alert
//        showAlert()
    }

    private func openPDFUrl() {
        let url = URL(string: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf")!
        if NSWorkspace.shared.open(url) {
            print("default browser was successfully opened")
        }
    }

    private func showAlert() {
        alert = NSAlert.init()
        alert?.messageText = "Title of message"
        alert?.informativeText = "Message description"
        alert?.addButton(withTitle: "OK")
        alert?.beginSheetModal(for: AppDelegate.shared.window)
    }
}

// MARK: - Drag file's/folder's
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

// MARK: - SFTP connect
extension HomeViewController {

    enum FTPUploadResult {
        case processing(FTPUploadProgress)
        case failure(Error)
    }

    struct FTPConfig {
        static let host: String = ""
        static let port: Int = 22
        static let username: String = ""
        static let password: String = ""
        static let folderPath: String = "/MyFolderOnFTPServer"
    }

    struct FTPUploadProgress {
        let originalBytes: Int
        let uploadedBytes: UInt

        var isFinished: Bool {
            uploadedBytes >= originalBytes
        }

        var percent: Double {
            (Double(uploadedBytes) / Double(originalBytes)) * 100
        }
    }

    private func testUploadFilesToFTP() {
        guard let fileUrl = Bundle.main.url(forResource: "DummyFile", withExtension: "zip") else { fatalError("🧨 File not found") }
        let uuid = UUID().uuidString
        let fileName = "Duy, Tran [\(uuid)]-[001].zip"
        uploadToFTPServer(from: fileUrl, with: fileName, completion: { result in
            switch result {
            case .processing(let progress):
                if progress.isFinished {
                    print("Uploaded to FTP: \(progress.uploadedBytes) bytes, percent: \(progress.percent)")
                } else {
                    print("Uploading: \(progress.uploadedBytes), percent: \(progress.percent)")
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }

    func uploadToFTPServer(from fileUrl: URL, with fileName: String, completion: @escaping ((FTPUploadResult) -> Void)) {
        let session = NMSSHSession.init(host: FTPConfig.host, port: FTPConfig.port, andUsername: FTPConfig.username)
        session.connect()
        if session.isConnected {
            session.authenticate(byPassword: FTPConfig.password)
            if session.isAuthorized {
                let sftpSession = NMSFTP(session: session)
                sftpSession.connect()
                if sftpSession.isConnected {
                    do {
                        if try fileUrl.checkResourceIsReachable() {
                            let data = try Data(contentsOf: fileUrl, options: [.alwaysMapped, .uncached])
                            let ftpRemotePath = FTPConfig.folderPath + "/\(fileName)"
                            sftpSession.writeContents(data, toFileAtPath: ftpRemotePath) { progress in
                                let currentProgress = FTPUploadProgress(originalBytes: data.count, uploadedBytes: progress)
                                completion(.processing(currentProgress))
                                return true
                            }
                        }
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
        }
    }
}
