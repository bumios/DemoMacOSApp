//
//  DragView.swift
//  DemoMacOSXIB
//
//  Created by Quang Bien on 20/06/2022.
//

import Cocoa

@objc protocol DragViewDelegate {
    func dragViewDidReceive(fileURLs: [URL])
}


class DragView: NSView {
    
    
    @IBOutlet weak var delegate: DragViewDelegate?
    let fileExtensions = ["pdf", "png", "zip", "folder", "Folder"]
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        color(to: .clear)
//        registerForDraggedTypes([.fileURL, .URL, .fileContents])
        registerForDraggedTypes(NSFilePromiseReceiver.readableDraggedTypes.map{ NSPasteboard.PasteboardType($0) })
    }
    
    override func draggingEntered(_ draggingInfo: NSDraggingInfo) -> NSDragOperation {
        var containsMatchingFiles = false
        draggingInfo.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: nil)?.forEach {
            eachObject in
            if let eachURL = eachObject as? URL {
                containsMatchingFiles = containsMatchingFiles || fileExtensions.contains(eachURL.pathExtension.lowercased())
                if containsMatchingFiles { print(eachURL.path) }
            }
        }
        
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
        draggingInfo.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: nil)?.forEach {
            eachObject in
            if let eachURL = eachObject as? URL,
               fileExtensions.contains(eachURL.pathExtension.lowercased()) {
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
