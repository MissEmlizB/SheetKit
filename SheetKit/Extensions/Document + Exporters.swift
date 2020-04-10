//
//  Document + Exporters.swift
//  SheetKit
//
//  Created by Emily Blackwell on 10/04/2020.
//  Copyright © 2020 Emily Blackwell. All rights reserved.
//

import Cocoa
import ImageIO


// Template placeholders
fileprivate let phClassName = "$NAME$"
fileprivate let phCount = "$COUNT$"
fileprivate let phSheet = "$SPRITESHEET_NAME$"
fileprivate let phAnimations = "$ANIMATIONS$"
fileprivate let phTextures = "$TEXTURES$"

extension Document {

	struct GIFData {
		var name: String
		var data: Data
	}
	
	struct ImageSequenceData {
		var name: String
		var images: [Data]
	}
	
	// MARK: Exporters
	
	func exportToGIF(completion: (@escaping ([GIFData]) -> ())) {
		
		guard let spritesheet = self.spritesheet else {
			return
		}
		
		DispatchQueue.global(qos: .userInitiated).async {
		
			var gifs: [GIFData] = []
			
			// Create an individual GIF for each animation
			for animation in self.animations {
				
				let imageData = NSMutableData()
				let frames = animation.makeImages(from: spritesheet)
				
				let gifProperty = [kCGImagePropertyGIFDictionary:
					[kCGImagePropertyGIFLoopCount: 0]] as CFDictionary
				
				guard let imageDestination = CGImageDestinationCreateWithData(imageData, kUTTypeGIF, frames.count, nil) else {
					continue
				}
				
				// Loop forever
				CGImageDestinationSetProperties(imageDestination, gifProperty)
				
				// Animation speed
				let speedProperty = [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFDelayTime: animation.speed]] as CFDictionary

				// Add its frames into the image
				for frame in frames {
					
					guard let image = frame.cgImage else {
						continue
					}
					
					CGImageDestinationAddImage(imageDestination, image, speedProperty)
				}
				
				// Finalise and add it to our GIF array
				guard CGImageDestinationFinalize(imageDestination) else {
					continue
				}
				
				let gif = GIFData(name: animation.name, data: imageData as Data)
				gifs.append(gif)
			}
			
			DispatchQueue.main.async {
				completion(gifs)
			}
		}
	}
	
	func exportToImageSequence(completion: (@escaping ([ImageSequenceData]) -> ())) {
		
		guard let spritesheet = self.spritesheet else {
			return
		}
		
		DispatchQueue.global(qos: .userInitiated).async {
			
			var sequences: [ImageSequenceData] = []
			
			for animation in self.animations {
				
				let frames = animation.makeImages(from: spritesheet)
					.compactMap { $0.pngRepresentation }
				
				let sequence = ImageSequenceData(name: animation.name, images: frames)
				sequences.append(sequence)
			}
			
			DispatchQueue.main.async {
				completion(sequences)
			}
		}
	}
	
	func exportSpritesheet(name: String, completion: ((String) -> ())) {
		
		let className = self.classMethodName(for: name).capitaliseFC
		
		// Replace placeholders in our class template
		var template = String.fromNamedAsset("sheet_template")
		template.replace(phClassName, with: className)
		template.replace(phCount, with: "\(self.animations.count)")
		template.replace(phSheet, with: name)
		
		// Add animations and textures
		var animations = "\n"
		var textures = "\n"
		
		for animation in self.animations {
			
			let name = classMethodName(for: animation.name).lowercased()
			
			let w = animation.size.width
			let h = animation.size.height
			
			let animationLine = [
				"\tlet \(name)_a = ",
				"SHKAnimation(size: CGSize(width: \(w), height: \(h)), ",
				"count: \(animation.count), ",
				"row: \(animation.row), column: \(animation.column), ",
				"speed: \(animation.speed))"
			]
			
			let textureLine = [
				"\tpublic var \(name): [SKTexture] { \n",
				"\t\tshkTextures(from: \(name)_a, spritesheet: self.image) \n",
				"\t}"
			]
			
			animations.append("\(animationLine.joined())\n")
			textures.append("\(textureLine.joined())\n")
		}
		
		template.replace(phAnimations, with: animations)
		template.replace(phTextures, with: textures)
		
		completion(template)
	}
	
	private func classMethodName(for name: String) -> String {

		let name = name.upperCamelCased
		let mutableClassName = NSMutableString(string: name)
		let allowedCharacters = try! NSRegularExpression(pattern: "[^a-z0-9]", options: .caseInsensitive)

		// Make sure that its class name is useable in Swift
		allowedCharacters.replaceMatches(in: mutableClassName, options: .withoutAnchoringBounds, range: name.nsrange, withTemplate: "")

		return String(mutableClassName)
	}
}
