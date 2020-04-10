//
//  WindowController.swift
//  SheetKit
//
//  Created by Emily Blackwell on 09/04/2020.
//  Copyright © 2020 Emily Blackwell. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
	
	@IBOutlet weak var exportIndicator: NSProgressIndicator!
	let model = ViewModel()
	
    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
 
		let viewController = self.contentViewController as! ViewController
		viewController.model = self.model
		model.delegate = viewController
	}
	
	// MARK: Actions
	@IBAction func openSpritesheet(sender: AnyObject) {
		 
		let panel = NSOpenPanel()
		panel.allowsMultipleSelection = false
		panel.resolvesAliases = true
		panel.allowedFileTypes = NSImage.imageTypes
		
		// Ask the user to open a spritesheet file
		panel.beginSheetModal(for: self.window!) {
			
			guard $0 == .OK,
				let photoURL = panel.url,
				let photo = NSImage(contentsOf: photoURL) else {
				return
			}
			
			self.model.setSpritesheet(photo: photo)
			self.model.document.updateChangeCount(.changeDone)
		}
	}
	
	@IBAction func addAnimation(sender: AnyObject) {
		model.addAnimation()
	}
	
	@IBAction func removeAnimation(sender: AnyObject) {
		model.removeAnimation()
	}
	
	// MARK: Export Actions
	
	@IBAction func exportToSpriteKit(sender: AnyObject) {
		
		guard let spritesheet = self.model.document.spritesheet,
			let spritesheetData = spritesheet.pngRepresentation else {
			return
		}
		
		let exportPanel = NSSavePanel()
		exportIndicator.setActive(true)
		
		exportPanel.beginSheetModal(for: self.window!) {
			
			guard $0 == .OK, let url = exportPanel.url else {
				return
			}
			
			let name = url.lastPathComponent
			let exportDirectory = FileWrapper(directoryWithFileWrappers: [:])
			
			self.model.document.exportSpritesheet(name: name) { template in
				
				// Class template file
				let templateData = template.data(using: .utf8)!
				let classFile = FileWrapper(regularFileWithContents: templateData)
				
				classFile.preferredFilename = "\(name).swift"
				exportDirectory.addFileWrapper(classFile)
				
				// Spritesheet file
				let spritesheetFile = spritesheetData
					.toFileWrapper(withPrefferedName: "\(name).png")
				
				exportDirectory.addFileWrapper(spritesheetFile)
				
				// SheetKit classes
				exportDirectory.addNamedAsset("sheet_animation", filename: "SHKAnimation.swift")
				exportDirectory.addNamedAsset("sheet_extensions", filename: "SheetKit Extensions.swift")
				exportDirectory.addNamedAsset("sheet_spritesheet", filename: "SHKSpritesheet.swift")
				
				self.exportIndicator.setActive(false)
				try? exportDirectory.write(to: url, options: .atomic, originalContentsURL: nil)
			}
		}
	}
	
	@IBAction func exportToDirectory(sender: AnyObject) {
		
		let exportPanel = NSSavePanel()
		exportIndicator.setActive(true)
		
		self.model.document.exportToImageSequence { sequences in
			
			self.exportIndicator.setActive(false)
			let exportDirectory = FileWrapper(directoryWithFileWrappers: [:])
			
			exportPanel.beginSheetModal(for: self.window!) {
				
				guard $0 == .OK, let url = exportPanel.url else {
					return
				}
				
				// Each animation would get their own directory
				for sequence in sequences {
					let animationDirectory = FileWrapper(directoryWithFileWrappers: [:])
					animationDirectory.preferredFilename = sequence.name
					
					for (i, frame) in sequence.images.enumerated() {
						
						let frameFile = FileWrapper(regularFileWithContents: frame)
						frameFile.preferredFilename = "\(sequence.name)-\(i).png"
						
						animationDirectory.addFileWrapper(frameFile)
					}
					
					exportDirectory.addFileWrapper(animationDirectory)
				}
				
				try? exportDirectory.write(to: url, options: .atomic, originalContentsURL: nil)
			}
		}
	}
	
	@IBAction func exportToGIF(sender: AnyObject) {
		
		let exportPanel = NSSavePanel()
		exportIndicator.setActive(true)
		
		self.model.document.exportToGIF { gifs in
			
			self.exportIndicator.setActive(false)
			let exportDirectory = FileWrapper(directoryWithFileWrappers: [:])
			
			exportPanel.beginSheetModal(for: self.window!) {
				guard $0 == .OK, let url = exportPanel.url else {
					return
				}
				
				// Export animations as individual GIFs
				for gif in gifs {
					let gifFile = FileWrapper(regularFileWithContents: gif.data)
					gifFile.preferredFilename = "\(gif.name).gif"
					
					exportDirectory.addFileWrapper(gifFile)
				}
				
				try? exportDirectory.write(to: url, options: .atomic, originalContentsURL: nil)
			}
		}
	}
}
