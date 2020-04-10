//
//  ViewModel + Inspector Delegate.swift
//  SheetKit
//
//  Created by Emily Blackwell on 09/04/2020.
//  Copyright © 2020 Emily Blackwell. All rights reserved.
//

import Cocoa


extension ViewModel: AnimationInspectorViewControllerDelegate {
	
	func propertyChanged(property: AnimationInspectorProperty, value: Any) {
		switch property {
			case .name:
				self.selectedAnimation?.name = String.fromAny(value)
			
			case .size:
				self.selectedAnimation?.size = CGSize.fromAny(value)
			
			case .count:
				self.selectedAnimation?.count = Int.fromAny(value)
			
			case .offsetX:
				self.selectedAnimation?.column = Int.fromAny(value)
			
			case .offsetY:
				self.selectedAnimation?.row = Int.fromAny(value)
			
			case .speed:
				self.selectedAnimation?.speed = Float.fromAny(value, default: 0.07)
		}
		
		// Apply and preview changes
		self.tableView.reloadData(forRowIndexes: [self.tableView.selectedRow],
								  columnIndexes: [0, 1])
		
		if let animation = self.selectedAnimation {
			self.delegate?.previewAnimation(animation: animation)
		}
	}
}
