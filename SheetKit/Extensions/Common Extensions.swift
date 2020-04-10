//
//  Common Extensions.swift
//  Poetic
//
//  Created by Emily Blackwell on 20/03/2020.
//  Copyright © 2020 Emily Blackwell. All rights reserved.
//

import Foundation

#if os(macOS)
import Cocoa
#endif

// MARK: Cocoa
#if os(macOS)

/// Creates a storyboard item ID from a string
/// - Parameter id: the item's identifier
func SUID(_ id: String) -> NSUserInterfaceItemIdentifier {
	return NSUserInterfaceItemIdentifier(rawValue: id)
}

#endif

// MARK: String

extension String {
	
	func index(_ i: Int) -> String.Index {
		return String.Index(utf16Offset: i, in: self)
	}
	
	var nsrange: NSRange {
		NSMakeRange(0, self.count)
	}

	var l: String {
		NSLocalizedString(self, comment: "")
	}
	
	var capitaliseFC: String {
		
		guard self.count > 0 else {
			return self
		}
		
		let fc = String(self[index(0)]).uppercased()
		let oc = String(self[index(1)...])
		
		return "\(fc)\(oc)"
	}
	
	mutating func replace(_ a: String, with b: String) {
		self = self.replacingOccurrences(of: a, with: b)
	}
	
	// Camelcase
	// https://gist.github.com/stevenschobert/540dd33e828461916c11
	
	func capitalizingFirstLetter() -> String {
		return prefix(1).uppercased() + dropFirst()
	}

	var upperCamelCased: String {
		return self.lowercased()
			.split(separator: " ")
			.map { return $0.lowercased().capitalizingFirstLetter() }
			.joined()
	}
   
	var lowerCamelCased: String {
		let upperCased = self.upperCamelCased
		return upperCased.prefix(1).lowercased() + upperCased.dropFirst()
	}
}

// MARK: Notification Centre

extension NotificationCenter {
	
	static func post(_ name: NCName, info userInfo: [AnyHashable: Any]? = nil, object: Any? = nil, onMain main: Bool = false) {
		
		let centre = NotificationCenter.default
		
		if main {
			DispatchQueue.main.async {
				centre.post(name: name, object: object, userInfo: userInfo)
			}
		}
		
		else {
			centre.post(name: name, object: object, userInfo: userInfo)
		}
	}
	
	static func post(_ name: NCName, value object: Any? = nil, info userInfo: [AnyHashable: Any]? = nil, onMain main: Bool = false) {
	
		NotificationCenter.post(name, info: userInfo, object: object, onMain: main)
	}
	
	static func observe(_ name: NCName, using selector: Selector, on observer: Any, watch object: Any? = nil) {
		
		let centre = NotificationCenter.default
		centre.addObserver(observer, selector: selector, name: name, object: object)
	}
	
	static func stopObserving(_ name: NCName, on observer: Any, specifically object: Any? = nil) {
		
		let centre = NotificationCenter.default
		centre.removeObserver(observer, name: name, object: object)
	}
}

extension NSNotification.Name {
	
	static func name(_ string: String) -> NSNotification.Name {
		return NSNotification.Name(rawValue: string)
	}
}

// MARK: Accessibility

#if os(macOS)

func alert(title: String, message: String, style: NSAlert.Style = .informational) {
	
	let alert = NSAlert()
	
	alert.messageText = title
	alert.informativeText = message
	alert.alertStyle = style
	alert.addButton(withTitle: "ok".l)
	
	alert.runModal()
}

extension NSAccessibility {
	
	static var reducedMotionEnabled: Bool {
		get {
			if #available(macOS 10.12, *) {
				return NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
			}
			
			else {
				return false
			}
		}
	}

	static var highContrastEnabled: Bool {
		get {
			NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast
		}
	}
}

#endif

// MARK: Colour

#if os(macOS)

extension NSColor {
	
	static var accentColour: NSColor {
		get {
			if #available(macOS 10.14, *) {
				return .controlAccentColor
			}
			
			else {
				return .systemBlue
			}
		}
	}
}

#endif

// MARK: Data

extension Data {
	
	static func namedAsset(_ name: String) -> Data? {
		return NSDataAsset(name: name)?.data
	}
	
	func toString(encoding: String.Encoding = .utf8, default dv: String = "") -> String {
		return String(data: self, encoding: encoding) ?? dv
	}
	
	func toFileWrapper(withPrefferedName name: String) -> FileWrapper {
		
		let fileWrapper = FileWrapper(regularFileWithContents: self)
		fileWrapper.preferredFilename = name
		
		return fileWrapper
	}
}

extension FileWrapper {
	
	func addNamedAsset(_ name: String, filename: String) {
		
		guard let asset = Data.namedAsset(name) else {
			return
		}
		
		self.addFileWrapper(asset.toFileWrapper(withPrefferedName: filename))
	}
}

extension String {
	
	static func fromNamedAsset(_ name: String, encoding: String.Encoding = .utf8, default dv: String = "") -> String {

		if let data = Data.namedAsset(name) {
			return data.toString(encoding: encoding, default: dv)
		}
		
		return dv
	}
}

// MARK: Images

#if os(macOS)

extension NSImage {
	/// NSImage to CGImage
	var cgImage: CGImage? {
		get {
			var frame = CGRect(origin: .zero, size: self.size)
			return self.cgImage(forProposedRect: &frame, context: .current, hints: [:])
		}
	}
	
	var pngRepresentation: Data? {
		get {
			guard let tiff = self.tiffRepresentation else {
				return nil
			}
			
			let representation = NSBitmapImageRep(data: tiff)
			return representation?.representation(using: .png, properties: [:])
		}
	}
}

extension CGImage {
	/// CGImage to NSImage
	func toImage(size: CGSize) -> NSImage {
		return NSImage(cgImage: self, size: size)
	}
}

#endif

// MARK: Aliases

typealias NC = NotificationCenter
typealias NCName = NSNotification.Name

// MARK: Any to Type

extension String {
	static func fromAny(_ t: Any?, default value: String = "n/a") -> String {
		return (t as? String) ?? value
	}
}

extension Int {
	static func fromAny(_ t: Any?, default value: Int = 0) -> Int {
		return (t as? Int) ?? value
	}
}

extension Double {
	static func fromAny(_ t: Any?, default value: Double = 0.0) -> Double {
		return (t as? Double) ?? value
	}
	
	var floatValue: Float {
		get {
			return Float(self)
		}
	}
	
	var cgfValue: CGFloat {
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

extension Float {
	static func fromAny(_ t: Any?, default value: Float = 0.0) -> Float {
		return (t as? Float) ?? value
	}
	
	var doubleValue: Double {
		get {
			return Double(self)
		}
	}
	
	var cgfValue: CGFloat {
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
	static func fromAny(_ t: Any?, default value: CGFloat = 0.0) -> CGFloat {
		return (t as? CGFloat) ?? value
	}
	
	var floatValue: Float {
		get {
			return Float(self)
		}
	}
	
	var doubleValue: Double {
		get {
			return Double(self)
		}
	}
}

extension CGSize {
	static func fromAny(_ t: Any?, default value: CGSize = .zero) -> CGSize {
		return (t as? CGSize) ?? value
	}
}

extension Bool {
	static func fromAny(_ t: Any?, default value: Bool = false) -> Bool {
		return (t as? Bool) ?? value
	}
}

// MARK: Number Separators

extension Numeric {
	func string(withSeperator separator: String, style: NumberFormatter.Style = .decimal) -> String {
		
		let formatter = NumberFormatter()
        formatter.groupingSeparator = separator
        formatter.numberStyle = style
		
        return formatter.string(for: self) ?? ""
    }
}

#if os(macOS)

// MARK: Convenient Cocoa

extension NSProgressIndicator {
	
	func setActive(_ active: Bool) {
		
		self.isHidden = !active
		active ? self.startAnimation(self) : self.stopAnimation(self)
	}
}

#endif
