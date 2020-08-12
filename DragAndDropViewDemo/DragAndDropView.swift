//
//  DragAndDropView.swift
//  DragAndDropViewDemo
//
//  Created by HIROKI IKEUCHI on 2020/08/12.
//  Copyright © 2020 hikeuchi. All rights reserved.
//

import Cocoa


protocol DragAndDropViewDelegate: class {
    func dragAndDropView(_ view: DragAndDropView,
                         didDragImageFileURLs draggedImages: [DraggedImage])
}

class DragAndDropView: NSView {
    
    var delegate: DragAndDropViewDelegate?
    
    // Viewがドラッグを許可するファイルのタイプ
    let acceptableTypes: [NSPasteboard.PasteboardType] = [.fileURL, .tiff, .png, .URL, .string]
    
    // URL先の画像のUTIが、NSImage.imageTypesのUTIに合致するかという条件
    let filteringOptions: [NSPasteboard.ReadingOptionKey : Any] = [.urlReadingContentsConformToTypes : NSImage.imageTypes]
    
    // ViewのUI制御用
    var isDragging = false {
        didSet {
            needsDisplay = true
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // ドラッグされている場合にハイライトさせる
        if isDragging {
            NSColor.selectedControlColor.set()
        } else {
            NSColor.windowFrameColor.set()
        }
        
        let path = NSBezierPath(rect: bounds)
        path.lineWidth = 5
        path.stroke()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.registerForDraggedTypes(acceptableTypes)
    }
    
    
    // MARK: - Helper Methods
    
    func shouldAllowDrag(_ draggingInfo: NSDraggingInfo) -> Bool {
        var canAccept = false
        let pasteBoard = draggingInfo.draggingPasteboard
        
        if pasteBoard.canReadObject(forClasses: [NSURL.self], options: nil) ||
            pasteBoard.canReadObject(forClasses: [NSImage.self], options: nil) {
            canAccept = true
        }
        
        return canAccept
    }
    
    func uti(url: URL) -> String? {
        guard let r = try? url.resourceValues(forKeys: [.typeIdentifierKey]) else {
            return nil
        }
        return r.typeIdentifier
    }
    
    
    // MARK:- NSDraggingDestination Protocol Methods
    
    /// Viewの境界にファイルがドラッグされるときに呼ばれる
    /// 宛先がどのドラッグ操作を実行するのかを示す値を返す必要があります。
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let allow = shouldAllowDrag(sender)
        isDragging = allow
        
        // NSDragOperation.copy := The data represented by the image can be copied.
        return allow ? NSDragOperation.copy : NSDragOperation()
    }
    
    /// View上にファイルがドラッグで保持されている間、短い間隔毎に呼ばれるメソッド
    /// 宛先がどのドラッグ操作を実行するのかを示す値を返す必要があります。
    //    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
    //    }
    
    /// View上にファイルがドラッグされなくなった際に呼ばれる
    override func draggingExited(_ sender: NSDraggingInfo?) {
        isDragging = false
    }
    
    /// View上でファイルがドロップされた際に呼ばれる
    /// メッセージが返された場合はYES、performDragOperation:メッセージが送信されます。
    //    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
    //    }
    
    /// View上でファイルがドロップされた後の処理
    override func performDragOperation(_ draggingInfo: NSDraggingInfo) -> Bool {
        
        isDragging = false
        let pasteBoard = draggingInfo.draggingPasteboard
        
        // fileURLがドラッグされた場合
        if let urls = pasteBoard.readObjects(forClasses: [NSURL.self], options: filteringOptions) as? [URL],
            urls.count > 0,
            urls[0].isFileURL {
            var draggedImages = [DraggedImage]()
            for url in urls {
                let uti = self.uti(url: url)
                draggedImages.append(DraggedImage(image: nil, url: url, uti: uti))
            }
            
            delegate?.dragAndDropView(self, didDragImageFileURLs: draggedImages)
            return true
        }
        
        // 画像イメージがドラッグされた場合
        if let pasteboardItems = pasteBoard.pasteboardItems {
            var draggedImages = [DraggedImage]()
            for pasteboardItem in pasteboardItems {
                for type in pasteboardItem.types {
                    if let data = pasteboardItem.data(forType: type) {
                        if let image = NSImage(data: data) {
                            draggedImages.append(DraggedImage(image: image, url: nil, uti: type.rawValue))
                        }
                    }
                }
            }
            
            if draggedImages.count > 0 {
                delegate?.dragAndDropView(self, didDragImageFileURLs: draggedImages)
                return true
            }
        }
        
        // 画像のURL(http://~)がドラッグされた場合
        if let urls = pasteBoard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL],
            urls.count > 0 {
            var draggedImages = [DraggedImage]()
            for url in urls {
                draggedImages.append(DraggedImage(image: nil, url: url, uti: nil))
            }
            
            delegate?.dragAndDropView(self, didDragImageFileURLs: draggedImages)
            return true
        }
        
        return false
    }
    
    /// 一連のドラッグ操作が完了したときに呼ばれる
    //    override func concludeDragOperation(_ sender: NSDraggingInfo?) {
    //    }
    
}
