//
//  DragView.swift
//  DemoMacOSXIB
//
//  Created by Quang Bien on 20/06/2022.
//

import Foundation
import Cocoa


@objc protocol DragViewDelegate {
    func dragViewDidReceive(fileURLs: [URL])
}


class DragView: NSView {
    
    
    @IBOutlet weak var delegate: DragViewDelegate?
    let fileExtensions = ["pdf", "png", "zip", "folder", "Folder"]
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        color(to: .red)
        registerForDraggedTypes([.fileURL, .URL, .fileContents])
//        registerForDraggedTypes(NSFilePromiseReceiver.readableDraggedTypes.map{ NSPasteboard.PasteboardType($0) })
    }
    override func draggingEntered(_ draggingInfo: NSDraggingInfo) -> NSDragOperation {
        var containsMatchingFiles = false
        draggingInfo.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: nil)?.forEach {
            eachObject in
            print((eachObject as? URL))
            if let eachURL = eachObject as? URL {
                containsMatchingFiles = containsMatchingFiles || fileExtensions.contains(eachURL.pathExtension.lowercased())
                if containsMatchingFiles { print(eachURL.path) }
            }
        }

        return .copy
        switch (containsMatchingFiles) {
        case true:
            color(to: .secondaryLabelColor)
            return .copy
        case false:
            color(to: .disabledControlTextColor)
            return .init()
        }
    }
    
    override func performDragOperation(_ draggingInfo: NSDraggingInfo) -> Bool {
        // Collect URLs.
        var matchingFileURLs: [URL] = []
        // NSString: Title email
        // NSUrl: Url của email

        let enumerator = FileManager.default.enumerator(atPath: "/Users/duytran/Library/Mail")!//NSHomeDirectory().appending("/Downloads"))!
        while let element = enumerator.nextObject() as? NSString {
            print("\(element.lastPathComponent), \(element.pathExtension)")
        }

        draggingInfo.draggingPasteboard.readObjects(forClasses: [NSURL.self])?.forEach {
//            po draggingInfo.draggingPasteboard.types?.forEach({ print("🌱\($0)", draggingInfo.draggingPasteboard.propertyList(forType: $0)) })
            eachObject in
            if let eachURL = eachObject as? URL {
//            if let eachURL = eachObject as? URL,
//               fileExtensions.contains(eachURL.pathExtension.lowercased()) {
                matchingFileURLs.append(eachURL)
            }
        }
        
        // Only if any,
        guard matchingFileURLs.count > 0 else { return false }
        
        // Pass to delegate.
        delegate?.dragViewDidReceive(fileURLs: matchingFileURLs)
        return true
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        color(to: .red.withAlphaComponent(0.5))
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        color(to: .clear)
    }
}


extension DragView {
    func color(to color: NSColor) {
        self.wantsLayer = true
        self.layer?.backgroundColor = color.cgColor
    }
}

//0 : NSPasteboardType
//  - _rawValue : com.apple.mail.PasteboardTypeMessageTransfer
//▿ 1 : NSPasteboardType
//  - _rawValue : com.apple.mail.PasteboardTypeAutomator
//▿ 2 : NSPasteboardType
//  - _rawValue : com.apple.pasteboard.promised-file-url
//▿ 3 : NSPasteboardType
//  - _rawValue : dyn.ah62d4rv4gu8y6y4usm1044pxqzb085xyqz1hk64uqm10c6xenv61a3k
//▿ 4 : NSPasteboardType
//  - _rawValue : NSPromiseContentsPboardType
//▿ 5 : NSPasteboardType
//  - _rawValue : com.apple.pasteboard.promised-file-content-type
//▿ 6 : NSPasteboardType
//  - _rawValue : dyn.ah62d4rv4gu8yc6durvwwa3xmrvw1gkdusm1044pxqyuha2pxsvw0e55bsmwca7d3sbwu
//▿ 7 : NSPasteboardType
//  - _rawValue : Apple files promise pasteboard type
//▿ 8 : NSPasteboardType
//  - _rawValue : public.url
//▿ 9 : NSPasteboardType
//  - _rawValue : CorePasteboardFlavorType 0x75726C20
//▿ 10 : NSPasteboardType
//  - _rawValue : dyn.ah62d4rv4gu8yc6durvwwaznwmuuha2pxsvw0e55bsmwca7d3sbwu
//▿ 11 : NSPasteboardType
//  - _rawValue : Apple URL pasteboard type
//▿ 12 : NSPasteboardType
//  - _rawValue : public.url-name
//▿ 13 : NSPasteboardType
//  - _rawValue : CorePasteboardFlavorType 0x75726C6E
//▿ 14 : NSPasteboardType
//  - _rawValue : public.utf8-plain-text
//▿ 15 : NSPasteboardType
//  - _rawValue : NSStringPboardType
