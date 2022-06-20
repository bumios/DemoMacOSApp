//
//  AppDelegate.swift
//  DemoMacOSXIB
//
//  Created by Duy Tran N. on 24/05/2022.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var window: NSWindow!

    static let shared: AppDelegate = {
        guard let appDelegate = NSApp.delegate as? AppDelegate else {
            return AppDelegate()
        }
        return appDelegate
    }()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let vc = HomeViewController()
        window.contentViewController = vc
    }

    func changeRootToLogin() {
        let vc = LoginViewController()
        window.contentViewController = vc
    }

    func changeRootToHome() {
        let vc = HomeViewController()
        window.contentViewController = vc
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
