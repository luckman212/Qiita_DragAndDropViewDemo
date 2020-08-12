//
//  DraggedImage.swift
//  DragAndDropViewDemo
//
//  Created by HIROKI IKEUCHI on 2020/08/12.
//  Copyright © 2020 hikeuchi. All rights reserved.
//

import Cocoa

struct DraggedImage {
    let image: NSImage?
    let url: URL?
    var uti: String?  // 拡張子情報
}
