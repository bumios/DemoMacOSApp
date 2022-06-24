//
//  CustomAlertViewController.swift
//  DemoMacOSXIB
//
//  Created by Duy Tran N. on 21/06/2022.
//

import Cocoa

final class CustomAlertViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    override func viewDidAppear() {
        super.viewDidAppear()
        print("viewDidAppear")
    }
}
