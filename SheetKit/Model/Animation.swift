//
//  Animation.swift
//  SheetKit
//
//  Created by Emily Blackwell on 09/04/2020.
//  Copyright © 2020 Emily Blackwell. All rights reserved.
//

import Cocoa


fileprivate let kName = "animation_name"
fileprivate let kWidth = "animation_size_width"
fileprivate let kHeight = "animation_size_height"
fileprivate let kCount = "animation_count"
fileprivate let kRow = "animation_y_offset"
fileprivate let kColumn = "animation_x_offset"
fileprivate let kSpeed = "animation_frame_speed"


/// An animation in the spritesheet
class Animation: NSObject, NSSecureCoding {
	
	/// The name of this animation
	var name: String = "def_aname".l
	
	/// The size of a single frame in the sprite sheet
	var size: CGSize = .zero
	
	/// The number of frames in this animation
	var count: Int = 0
	
	/// Which row does this animation start in the sprite sheet?
	var row: Int = 0
	
	/// Which column does this animation start in the sprite sheet?
	var column: Int = 0
	
	/// How fast should each frames last? (larger numbers == longer)
	var speed: Float = 0.07
	
	init(name: String, size: CGSize, count: Int, row: Int, column: Int = 0, speed: Float = 0.07) {
		
		super.init()
		
		self.name = name
		self.size = size
		self.count = count
		self.row = row
		self.column = column
		self.speed = speed
	}
	
	// MARK: Animation
	
	func makeImages(from sheet: NSImage) -> [NSImage] {
		
		guard let sheet = sheet.cgImage else {
			return []
		}
		
		var images: [NSImage] = []
		let y = self.size.height * CGFloat(self.row)
		
		// Slide-crop through the sprite sheet until we have every frame
		for i in 0 ..< self.count {
			
			let x = (CGFloat(self.column) * self.size.width) + (self.size.width * CGFloat(i))
			let point = CGPoint(x: x, y: y)
			
			let frame = CGRect(origin: point, size: self.size)
			
			guard let photo = sheet.cropping(to: frame) else {
				continue
			}
			
			images.append(photo.toImage(size: self.size))
		}
		
		return images
	}
	
	// MARK: Secure Coding
	
	static var supportsSecureCoding: Bool {
		return true
	}
	
	func encode(with coder: NSCoder) {
		
		coder.encode(name, forKey: kName)
		coder.encode(size.width.floatValue, forKey: kWidth)
		coder.encode(size.height.floatValue, forKey: kHeight)
		coder.encode(count, forKey: kCount)
		coder.encode(row, forKey: kRow)
		coder.encode(column, forKey: kColumn)
		coder.encode(speed, forKey: kSpeed)
	}
	
	required init?(coder: NSCoder) {
		
		// Name
		self.name = String.fromAny(coder.decodeObject(of: NSString.self, forKey: kName), default: "def_aname".l)
		
		// Frame size
		
		let width = Float.fromAny(coder.decodeFloat(forKey: kWidth))
		let height = Float.fromAny(coder.decodeFloat(forKey: kHeight))
			
		self.size = CGSize(width: width.cgfValue, height: height.cgfValue)
		
		// Count, row and column, and speed
		
		self.count = Int.fromAny(coder.decodeInteger(forKey: kCount))
		self.row = Int.fromAny(coder.decodeInteger(forKey: kRow))
		self.column = Int.fromAny(coder.decodeInteger(forKey: kColumn))
		
		// Speed should NEVER fall below zero
		self.speed = Float.fromAny(coder.decodeFloat(forKey: kSpeed), default: 0.07)
		
		if self.speed == 0.0 {
			self.speed = 0.07
		}
	}
}
