//
//  AnimationInspectorViewController.swift
//  SheetKit
//
//  Created by Emily Blackwell on 09/04/2020.
//  Copyright © 2020 Emily Blackwell. All rights reserved.
//

import Cocoa

enum AnimationInspectorProperty {
	case name
	case size
	case count
	case offsetX
	case offsetY
	case speed
}

protocol AnimationInspectorViewControllerDelegate {
	func propertyChanged(property: AnimationInspectorProperty, value: Any)
}

class AnimationInspectorViewController: NSViewController {
	
	@IBOutlet weak var nameTextField: NSTextField! {
		didSet {
			nameTextField.stringValue = template.name
		}
	}
	
	@IBOutlet weak var widthTextField: NSTextField! {
		didSet {
			widthTextField.integerValue = Int(template.size.width)
		}
	}
	
	@IBOutlet weak var heightTextField: NSTextField! {
		didSet {
			heightTextField.integerValue = Int(template.size.height)
		}
	}
	
	@IBOutlet weak var countTextField: NSTextField! {
		didSet {
			countTextField.integerValue = template.count
		}
	}
	
	@IBOutlet weak var offsetYTextField: NSTextField! {
		didSet {
			offsetYTextField.integerValue = template.row
		}
	}
	
	@IBOutlet weak var offsetXTextField: NSTextField! {
		didSet {
			offsetXTextField.integerValue = template.column
		}
	}
	
	@IBOutlet weak var speedTextField: NSTextField! {
		didSet {
			speedTextField.floatValue = template.speed
		}
	}
	
	var delegate: AnimationInspectorViewControllerDelegate?
	var template: Animation!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
	}
    
	// MARK: Actions
	@IBAction func nameChanged(sender: NSTextField) {
		
		let name = sender.stringValue
		
		guard !name.isEmpty else {
			return
		}
		
		delegate?.propertyChanged(property: .name, value: name)
	}
	
	@IBAction func sizeChanged(sender: NSTextField) {
		
		let width = widthTextField.integerValue
		let height = heightTextField.integerValue
		let size = CGSize(width: CGFloat(width), height: CGFloat(height))
		
		guard width >= 0 && height >= 0 else {
			return
		}
		
		delegate?.propertyChanged(property: .size, value: size)
	}
	
	@IBAction func countChanged(sender: NSTextField) {
		
		let count = sender.integerValue
		
		guard count >= 1 && count <= 100 else {
			return
		}
		
		delegate?.propertyChanged(property: .count, value: count)
	}
	
	@IBAction func offsetXChanged(sender: NSTextField) {
		
		let offset = sender.integerValue
		
		guard offset >= 0 else {
			return
		}
		
		delegate?.propertyChanged(property: .offsetX, value: offset)
	}
	
	@IBAction func offsetYChanged(sender: NSTextField) {
		
		let offset = sender.integerValue
		
		guard offset >= 0 else {
			return
		}
		
		delegate?.propertyChanged(property: .offsetY, value: offset)
	}
	
	@IBAction func speedChanged(sender: NSTextField) {
		
		let speed = sender.floatValue
		
		guard speed > 0 else {
			return
		}
		
		delegate?.propertyChanged(property: .speed, value: speed)
	}
}
