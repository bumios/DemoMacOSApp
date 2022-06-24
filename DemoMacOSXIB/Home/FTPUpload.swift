//
//  FTPUpload.swift
//  DemoMacOSXIB
//
//  Created by Duy Tran N. on 21/06/2022.
//

//import Foundation
//import CFNetwork
//
//public class FTPUpload {
//    fileprivate let ftpBaseUrl: String
//    fileprivate let directoryPath: String
//    fileprivate let username: String
//    fileprivate let password: String
//
//    public init(baseUrl: String, userName: String, password: String, directoryPath: String) {
//        self.ftpBaseUrl = baseUrl
//        self.username = userName
//        self.password = password
//        self.directoryPath = directoryPath
//    }
//}
//
//
//// MARK: - Steam Setup
//extension FTPUpload {
//    private func setFtpUserName(for ftpWriteStream: CFWriteStream, userName: CFString) {
//        let propertyKey = CFStreamPropertyKey(rawValue: kCFStreamPropertyFTPUserName)
//        CFWriteStreamSetProperty(ftpWriteStream, propertyKey, userName)
//    }
//
//    private func setFtpPassword(for ftpWriteStream: CFWriteStream, password: CFString) {
//        let propertyKey = CFStreamPropertyKey(rawValue: kCFStreamPropertyFTPPassword)
//        CFWriteStreamSetProperty(ftpWriteStream, propertyKey, password)
//    }
//
//    fileprivate func ftpWriteStream(forFileName fileName: String) -> CFWriteStream? {
//        let fullyQualifiedPath = "ftp://\(ftpBaseUrl)/\(directoryPath)/\(fileName)"
//
//        guard let ftpUrl = CFURLCreateWithString(kCFAllocatorDefault, fullyQualifiedPath as CFString, nil) else { return nil }
//        let ftpStream = CFWriteStreamCreateWithFTPURL(kCFAllocatorDefault, ftpUrl)
//        let ftpWriteStream = ftpStream.takeRetainedValue()
//        setFtpUserName(for: ftpWriteStream, userName: username as CFString)
//        setFtpPassword(for: ftpWriteStream, password: password as CFString)
//        return ftpWriteStream
//    }
//}
//
//
//// MARK: - FTP Write
//extension FTPUpload {
//    public func dummySend(success: @escaping((Bool) -> Void)) {
//        guard let fileUrl = Bundle.main.url(forResource: "DummyFile", withExtension: "zip") else {
//            fatalError("🧨 File not found")
//        }
//        do {
//            if try fileUrl.checkResourceIsReachable() {
//                let data = try Data(contentsOf: fileUrl, options: [.alwaysMapped, .uncached])
//                let uuid = UUID().uuidString
////                let fileName = "Shull,Mike[\(uuid)]-[001].zip"
//                let fileName = "ShullMike.zip"
////                /// Test format of file name
////                let fileNameWithSpace = "Shull, Mike [\(uuid)]-[001].zip"
////                var urlString = fileNameWithSpace.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
////                //
//                print("☘️ Sending data with file name: \(fileName)")
//                send(data: data, with: fileName) { isSuccess in
//                    success(isSuccess)
//                }
//            }
//        } catch {
//            print("Error", error.localizedDescription)
//        }
//    }
//
//    public func send(data: Data, with fileName: String, success: @escaping ((Bool)->Void)) {
//
//        guard let ftpWriteStream = ftpWriteStream(forFileName: fileName) else {
//            success(false)
//            return
//        }
//
//        if CFWriteStreamOpen(ftpWriteStream) == false {
//            print("Could not open stream")
//            success(false)
//            return
//        }
//
//        let fileSize = data.count
//        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: fileSize)
//        data.copyBytes(to: buffer, count: fileSize)
//
//        defer {
//            CFWriteStreamClose(ftpWriteStream)
////            buffer.deallocate(capacity: fileSize)
//            buffer.deallocate()
//        }
//
//        var offset: Int = 0
//        var dataToSendSize: Int = fileSize
//
//        repeat {
////            print(".", separator: "", terminator: "")
//            let bytesWritten = CFWriteStreamWrite(ftpWriteStream, &buffer[offset], dataToSendSize)
//            if bytesWritten > 0 {
//                offset += bytesWritten.littleEndian
//                dataToSendSize -= bytesWritten
//                continue
//            } else if bytesWritten < 0 {
//                // ERROR
//                print("FTPUpload - ERROR")
//                break
//            } else if bytesWritten == 0 {
//                // SUCCESS
//                print("FTPUpload - Completed!!")
//                break
//            }
//        } while (true)//CFWriteStreamCanAcceptBytes(ftpWriteStream)
//
//        success(true)
//    }
//}
