//
//  ViewController.swift
//  DragAndDropViewDemo
//
//  Created by HIROKI IKEUCHI on 2020/08/12.
//  Copyright © 2020 hikeuchi. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var dragAndDropView: DragAndDropView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dragAndDropView.delegate = self
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

extension ViewController: DragAndDropViewDelegate {
    func dragAndDropView(_ view: DragAndDropView, didDragImageFileURLs draggedImages: [DraggedImage]) {
        for draggedImage in draggedImages {
            print("\(draggedImage.url), \(draggedImage.uti)")
        }
    }
}
