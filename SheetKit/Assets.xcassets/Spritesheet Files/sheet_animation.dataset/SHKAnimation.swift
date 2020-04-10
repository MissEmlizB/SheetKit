#if os(macOS)
import Cocoa
#elseif os(iOS)
import UIKit
#endif

/// An animation in the spritesheet
public class SHKAnimation {

	/// The size of a single frame in the sprite sheet
	public var size: CGSize = .zero
	/// The number of frames in this animation
	public var count: Int = 0
	/// Which row does this animation start in the sprite sheet?
	public var row: Int = 0
	/// Which column does this animation start in the sprite sheet?
	public var column: Int = 0
	/// How fast should each frames last? (larger numbers == longer)
	public var speed: Float = 0.07
	
	public init(size: CGSize, count: Int, row: Int, column: Int = 0, speed: Float = 0.07) {
		self.size = size
		self.count = count
		self.row = row
		self.column = column
		self.speed = speed
	}
	
	// MARK: Animation
	
	public func makeImages(from sheet: SHKImage) -> [SHKImage] {
		
		guard let sheet = sheet.cgImage else {
			return []
		}
		
		var images: [SHKImage] = []
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
}
