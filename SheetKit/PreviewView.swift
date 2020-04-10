//
//  PreviewView.swift
//  SheetKit
//
//  Created by Emily Blackwell on 09/04/2020.
//  Copyright © 2020 Emily Blackwell. All rights reserved.
//

import SpriteKit

class PreviewView: SKView {
	
	var spritePreview: SKSpriteNode! {
		didSet {
			oldValue?.removeFromParent()
		}
	}
	
	override func viewDidMoveToWindow() {
		
		super.viewDidMoveToWindow()
		
		// Set up our scene
		let scene = SKScene(size: CGSize(width: 512, height: 512))
		scene.scaleMode = .aspectFill
		scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
		
		scene.backgroundColor = .gray
		self.presentScene(scene)
	}
	
	func setPreview(_ images: [NSImage], speed: TimeInterval = 0.07, scale: Float = 1.0) {
		
		let textures = images.map { SKTexture(image: $0) }
		
		guard let firstFrame = textures.first else {
			return
		}
		
		// Update our animated preview
		
		self.spritePreview = SKSpriteNode(texture: firstFrame)
		self.spritePreview.run(SKAction.repeatForever(
			SKAction.animate(with: textures, timePerFrame: speed)))
		
		let width = self.spritePreview.size.width
		let height = self.spritePreview.size.height
		
		self.spritePreview.size = CGSize(width: width * scale.cgfValue,
										 height: height * scale.cgfValue)
		
		scene?.addChild(self.spritePreview)
	}
	
	func clearPreview() {
		self.spritePreview?.removeFromParent()
	}
}
