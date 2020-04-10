import SpriteKit

#if os(macOS)
public typealias SHKImage = NSImage
#elseif os(iOS)
public typealias SHKImage = UIImage
#endif

// MARK: Images

#if os(macOS)

extension NSImage {
	/// NSImage to CGImage
	public var cgImage: CGImage? {
		get {
			var frame = CGRect(origin: .zero, size: self.size)
			return self.cgImage(forProposedRect: &frame, context: .current, hints: [:])
		}
	}
}

#endif

extension CGImage {
	/// CGImage to NSImage
	func toImage(size: CGSize) -> SHKImage {
		#if os(macOS)
		return SHKImage(cgImage: self, size: size)
		#elseif os(iOS)
		return SHKImage(cgImage: self)
		#endif
	}
}

// MARK: Any to Type

extension String {
	public static func fromAny(_ t: Any?, default value: String = "") -> String {
		return (t as? String) ?? value
	}
}

extension Int {
	public static func fromAny(_ t: Any?, default value: Int = 0) -> Int {
		return (t as? Int) ?? value
	}
}

extension Double {
	public static func fromAny(_ t: Any?, default value: Double = 0.0) -> Double {
		return (t as? Double) ?? value
	}
	
	public var floatValue: Float {
		get {
			return Float(self)
		}
	}
	
	public var cgfValue: CGFloat {
		get {
			return CGFloat(self)
		}
	}
	
	public var tintervalValue: TimeInterval {
		get {
			return TimeInterval(self)
		}
	}
}

extension Float {
	public static func fromAny(_ t: Any?, default value: Float = 0.0) -> Float {
		return (t as? Float) ?? value
	}
	
	public var doubleValue: Double {
		get {
			return Double(self)
		}
	}
	
	public var cgfValue: CGFloat {
		get {
			return CGFloat(self)
		}
	}
	
	var tintervalValue: TimeInterval {
		get {
			return TimeInterval(self)
		}
	}
}

extension CGFloat {
	public static func fromAny(_ t: Any?, default value: CGFloat = 0.0) -> CGFloat {
		return (t as? CGFloat) ?? value
	}
	
	public var floatValue: Float {
		get {
			return Float(self)
		}
	}
	
	public var doubleValue: Double {
		get {
			return Double(self)
		}
	}
}

extension CGSize {
	public static func fromAny(_ t: Any?, default value: CGSize = .zero) -> CGSize {
		return (t as? CGSize) ?? value
	}
}

extension Bool {
	public static func fromAny(_ t: Any?, default value: Bool = false) -> Bool {
		return (t as? Bool) ?? value
	}
}

// MARK: Animations

public func shkTextures(from animation: SHKAnimation, spritesheet sheet: SHKImage) -> [SKTexture] {
	return animation.makeImages(from: sheet)
		.map { SKTexture(image: $0) }
}
