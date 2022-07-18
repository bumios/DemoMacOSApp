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

    func changeRoot(to rootType: RootType) {
        var vc: NSViewController
        switch rootType {
        case .home:
            vc = HomeViewController()
        case .login:
            vc = LoginViewController()
        case .detail:
            vc = DetailInformationViewController()
        }

        window.contentViewController = vc
        window.center()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}

extension AppDelegate {

    enum RootType {
        case home
        case login
        case detail
    }
}
