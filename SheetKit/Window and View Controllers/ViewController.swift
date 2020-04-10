//
//  ViewController.swift
//  SheetKit
//
//  Created by Emily Blackwell on 09/04/2020.
//  Copyright © 2020 Emily Blackwell. All rights reserved.
//

import Cocoa
import SpriteKit

class ViewController: NSViewController {
	
	@IBOutlet weak var spritesheetView: NSImageView!
	@IBOutlet weak var animationsTableView: NSTableView!
	@IBOutlet weak var previewView: PreviewView!
	@IBOutlet weak var zoomSlider: NSSlider!
	
	weak var model: ViewModel!
	
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		animationsTableView.doubleAction = #selector(tableDoubleAction(sender:))
	}
}

extension ViewController: ViewModelDelegate {
	
	func clearPreview() {
		previewView.clearPreview()
	}

	func previewAnimation(animation: Animation) {
		
		guard let spritesheet = self.model?.document?.spritesheet else {
			return
		}
		
		let frames = animation.makeImages(from: spritesheet)
		
		previewView.setPreview(frames,
							   speed: animation.speed.tintervalValue,
							   scale: zoomSlider.floatValue / 100.0)
	}
	
	func documentIsReady() {
		
		// Load our animations
		animationsTableView.delegate = self.model
		animationsTableView.dataSource = self.model
		self.model.tableView = animationsTableView
		
		// Load our sprite sheet and previews
		if let spritesheet = self.model.document.spritesheet {
			self.spritesheetLoaded(spritesheet: spritesheet)
		}
	}
	
	func spritesheetLoaded(spritesheet: NSImage) {
		spritesheetView.image = spritesheet
		spritesheetView.enclosingScrollView?.magnify(toFit: spritesheetView.frame)
	}
	
	// MARK: Actions
	
	@objc func tableDoubleAction(sender: AnyObject) {
		self.model.openInspectorAtSelectedRow()
	}
	
	@IBAction func previewZoomChanged(sender: NSSlider?) {
		
		let selectedRow = animationsTableView.selectedRow
		
		guard selectedRow >= 0 && selectedRow < (self.model?.document?.animations.count ?? -1) else {
			
			return
		}
		
		let animation = self.model.document.animations[selectedRow]
		self.previewAnimation(animation: animation)
	}
	
	@IBAction func previewViewMagnified(sender: NSMagnificationGestureRecognizer) {
		
		let change = sender.magnification * 5.0
		zoomSlider.floatValue += change.floatValue
		
		self.previewZoomChanged(sender: nil)
	}
}
