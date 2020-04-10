//
//  ViewModel.swift
//  SheetKit
//
//  Created by Emily Blackwell on 09/04/2020.
//  Copyright © 2020 Emily Blackwell. All rights reserved.
//

import Cocoa


fileprivate let inspectorID = "Animation Inspector"

protocol ViewModelDelegate {
	func documentIsReady()
	func spritesheetLoaded(spritesheet: NSImage)
	func clearPreview()
	func previewAnimation(animation: Animation)
}

class ViewModel: NSObject {
	
	var delegate: ViewModelDelegate?
	weak var selectedAnimation: Animation?
	
	var popover: NSPopover! {
		didSet {
			self.selectedAnimation = nil
			oldValue?.close()
		}
	}
	
	weak var tableView: NSTableView!
	
	weak var document: Document! {
		didSet {
			delegate?.documentIsReady()
		}
	}
	
	// MARK: Actions
	
	func setSpritesheet(photo: NSImage) {
		
		self.document.spritesheet = photo
		self.delegate?.spritesheetLoaded(spritesheet: photo)
	}
	
	func addAnimation() {
		
		let row = self.document.animations.count
		let animation = Animation(name: "Animation", size: CGSize(width: 32, height: 32), count: 1, row: 0)
		
		self.document.animations.append(animation)
		tableView.insertRows(at: [row], withAnimation: .slideDown)
	}
	
	func removeAnimation() {
		
		let selectedRow = tableView.selectedRow
		
		guard selectedRow >= 0 && selectedRow < self.document.animations.count else {
			return
		}
		
		self.document.animations.remove(at: selectedRow)
		tableView.removeRows(at: [selectedRow], withAnimation: .slideUp)
	}
	
	func openInspectorAtSelectedRow() {
		
		let selectedRow = tableView.selectedRow
		
		guard selectedRow >= 0 && selectedRow < self.document.animations.count else {
			return
		}
		
		let cell = tableView.rowView(atRow: selectedRow, makeIfNecessary: false)
		
		// Create an inspector popover at the selected row
		self.popover = NSPopover()
		let storyboard = NSStoryboard(name: "Main", bundle: nil)
		
		let popoverVC = storyboard.instantiateController(withIdentifier: inspectorID) as! AnimationInspectorViewController
		
		let animation = self.document.animations[selectedRow]
		self.selectedAnimation = animation
		
		popoverVC.template = animation
		popoverVC.delegate = self
		
		popover.behavior = .semitransient
		popover.contentViewController = popoverVC
		popover.show(relativeTo: cell!.frame, of: tableView, preferredEdge: .minY)
	}
}
