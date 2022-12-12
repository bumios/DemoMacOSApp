//
//  HomeViewController.swift
//  DemoMacOSXIB
//
//  Created by Duy Tran N. on 24/05/2022.
//

import Cocoa
import NMSSH
import CwlUtils
import ZIPFoundation

final class HomeViewController: NSViewController {

    @IBOutlet private weak var inputTextField: NSTextField!
    @IBOutlet private weak var submitButton: NSButton!
    @IBOutlet private weak var tableView: NSTableView!
    @IBOutlet private weak var dragView: DragView!

    let viewModel = HomeViewModel()
    var draggedFileUrl: URL?

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
        showAlert()
    }

    @IBAction func dragEmailButtonTapped(_ sender: NSButton) {
        handleDragEmailButton()
    }

    @IBAction func collectDataButtonTapped(_ sender: NSButton) {
        if let fileUrl = draggedFileUrl {
            copyFileToMyFolder(at: fileUrl)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                self.zipFromMyFolderToDesktop()
//            }
            zipFromMyFolderToDesktop()
        }
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

// MARK: - Extension NSTableViewDataSource
extension HomeViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return viewModel.numberOfRows()
    }
}

// MARK: - Extension NSTableViewDelegate
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

// MARK: - Class IdentityInfoCellView
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

// MARK: - Drag file's/folder's
extension HomeViewController: DragViewDelegate {
    func dragViewDidReceive(fileURLs: [URL]) {
        print("-----", fileURLs)
        draggedFileUrl = fileURLs.first!
//        zipFile(url: fileURLs.first!)
    }
}

// MARK: - SFTP connect & upload
extension HomeViewController {

    enum FTPUploadResult {
        case processing(FTPUploadProgress)
        case failure(Error)
    }

    struct FTPConfig {
        static let host: String = "74.122.204.179"//"Duys-Mac-mini.local"//"74.122.204.179"
        static let port: Int = 22//22
        static let username: String = "ds-autostreem"//"myftpuser"//ds-autostreem
        static let password: String = "EnterprisePasswordTea_2021"//"Abc123@@"//"EnterprisePasswordTea_2021"
        static let folderPath: String = "/AutoStreemLite"//"/My-Local-SFTP-Folder"//"/AutoStreemLite"
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

// MARK: - Extension Zip/Move files
extension HomeViewController {

    private func handleDragEmailButton() {
        let desktopPath = (NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true) as [String]).first!
        let myFilePath = desktopPath + "/SelfCollection"

        do {
            /// `Create file`
            let manager = FileManager.default
            try manager.createDirectory(atPath: myFilePath, withIntermediateDirectories: true)

            /// `Open folder`
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: myFilePath)
        }
        catch {}
    }

    func copyFileToMyFolder(at fileUrl: URL) {
        let desktopPath = (NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true) as [String]).first!
        var myFolderURL = URL(fileURLWithPath: desktopPath)
        myFolderURL.appendPathComponent("SelfCollection")

        /// `Create directory`
        #warning("Tìm hiểu NSFileManagerDelegate để tracking trạng thái tạo file, xóa file kẻo code chạy đồng bộ sẽ toang")
        do {
            if !FileManager.default.fileExists(atPath: myFolderURL.path) {
                try FileManager.default.createDirectory(atPath: myFolderURL.path, withIntermediateDirectories: true, attributes: nil)
            } else {
//                try FileManager.default.removeItem(at: myFolderURL)
            }
        } catch let error as NSError {
            print("🧨 \(#function): \(error)")
        }

        ///  `Copied file & move to new folder`
        let destinationUrl = myFolderURL.appendingPathComponent(fileUrl.lastPathComponent)
        do {
            print("🌱 \(#function)")
            try FileManager.default.linkItem(at: fileUrl, to: destinationUrl)
        } catch {
            print("🧨 \(#function): \(error)")
        }
    }

    private func zipFromMyFolderToDesktop() {
        let fileManager = FileManager()
        let desktopPath = (NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true) as [String]).first!
        let myFilePath = desktopPath + "/SelfCollection/"
        let sourceURL = URL(fileURLWithPath: myFilePath)
        var destinationURL = URL(fileURLWithPath: desktopPath)
        destinationURL.appendPathComponent("MyArchieved.zip")
        do {
            try fileManager.zipItem(at: sourceURL, to: destinationURL)
            print("🌱 \(#function)")
        } catch {
            print("🧨 \(#function): \(error)")
        }
    }

    private func deleteMyFolder() {
        let desktopPath = (NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true) as [String]).first!
        let myFilePath = desktopPath + "/SelfCollection"

        do {
            // Xóa hẳn luôn
            try FileManager.default.removeItem(atPath: myFilePath)
            // Đưa vô trash
            try FileManager.default.trashItem(at: URL(fileURLWithPath: myFilePath), resultingItemURL: nil)
        } catch {
            print("🧨 \(#function): \(error)")
        }
    }
}

// MARK: - Library CwlUtils
extension HomeViewController {
    func printHardwareInformation() {
        print("cpuFreq: \(Sysctl.cpuFreq)")
        print("activeCPUs: \(Sysctl.activeCPUs)")
        print("hostName: \(Sysctl.hostName)")
        print("machine: \(Sysctl.machine)")
        print("memSize: \(Sysctl.memSize)")
        print("model: \(Sysctl.model)")
        print("osRelease: \(Sysctl.osRelease)")
        print("osRev: \(Sysctl.osRev)")
        print("osType: \(Sysctl.osType)")
        print("osVersion: \(Sysctl.osVersion)")
        print("version: \(Sysctl.version)")
    }
}
