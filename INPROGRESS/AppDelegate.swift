//
//  AppDelegate.swift
//  AutoStreemLite
//
//  Created by Duy Tran N. on 12/10/2022.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1480, height: 950),
                    styleMask: [.miniaturizable, .closable, .resizable, .titled],
                    backing: .buffered, defer: true)
        window.contentViewController = MainScreenViewController()
        window.contentViewController?.view.window?.delegate = self
        window.center()
        window.title = "AutoStreem Liteeeeeeee"
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        NSApplication.shared.unhide(self)
    }
}

extension AppDelegate: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        NSApplication.shared.hide(self)
        return false
    }
}
