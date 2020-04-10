//
//  Document.swift
//  SheetKit
//
//  Created by Emily Blackwell on 09/04/2020.
//  Copyright © 2020 Emily Blackwell. All rights reserved.
//

import Cocoa


fileprivate let kSpritesheet = "spritesheet_image.tiff"
fileprivate let kAnimations = "spritesheet_animations"

class Document: NSDocument {
	
	private var fileWrapper: FileWrapper!
	static let loadNotification = NCName(rawValue: "documentWasLoaded")
	
	var spritesheet: NSImage? {
		didSet {
			
			guard let tiff = spritesheet?.tiffRepresentation else {
				return
			}
			
			let file = FileWrapper(regularFileWithContents: tiff)
			file.preferredFilename = kSpritesheet
			
			// Remove the previous spritesheet (if it exists)
			if let efile = self.fileWrapper.fileWrappers?[kSpritesheet] {
				self.fileWrapper.removeFileWrapper(efile)
			}
			
			self.fileWrapper.addFileWrapper(file)
		}
	}
	
	var animations: [Animation] = []

	override init() {
	    super.init()
		
		// Add your subclass-specific initialization here.
		self.fileWrapper = FileWrapper(directoryWithFileWrappers: [:])
	}
	
	override class func canConcurrentlyReadDocuments(ofType typeName: String) -> Bool {
		return true
	}

	override class var autosavesInPlace: Bool {
		return true
	}

	override func makeWindowControllers() {
		
		// Returns the Storyboard that contains your Document window.
		let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
		let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! WindowController
		
		windowController.model.document = self
		self.addWindowController(windowController)
	}
	
	// MARK: File Wrappers

	override func write(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, originalContentsURL absoluteOriginalContentsURL: URL?) throws {
		
		let data = NSMutableData()
		let coder = NSKeyedArchiver(forWritingWith: data)
		coder.requiresSecureCoding = true
		
		coder.encode(self.animations, forKey: kAnimations)
		coder.finishEncoding()
		
		let animationsFile = FileWrapper(regularFileWithContents: data as Data)
		animationsFile.preferredFilename = kAnimations
		
		if let eafile = self.fileWrapper.fileWrappers?[kAnimations] {
			self.fileWrapper.removeFileWrapper(eafile)
		}
		
		self.fileWrapper.addFileWrapper(animationsFile)
		try? self.fileWrapper.write(to: url, options: .atomic, originalContentsURL: absoluteOriginalContentsURL)
	}

	override func read(from fileWrapper: FileWrapper, ofType typeName: String) throws {

		// Load our animations file
		
		guard let animationsFile = fileWrapper.fileWrappers?[kAnimations],
			let animationsData = animationsFile.regularFileContents else {
			return
		}
		
		let coder = NSKeyedUnarchiver(forReadingWith: animationsData)
		coder.requiresSecureCoding = true
		
		guard let objects = coder.decodeObject(of: [NSArray.self, Animation.self], forKey: kAnimations),
			let animations = objects as? [Animation] else {
				return
		}
		
		// Load our sprite sheet
		
		guard let spritesheet = fileWrapper.fileWrappers?[kSpritesheet],
			let tiffData = spritesheet.regularFileContents,
			let photo = NSImage(data: tiffData) else {
				return
		}
		
		self.spritesheet = photo
		self.animations = animations
		self.fileWrapper = fileWrapper
		
		NC.post(Document.loadNotification, value: self)
	}
}

