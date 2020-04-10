//
//  ViewModel + Table View.swift
//  SheetKit
//
//  Created by Emily Blackwell on 09/04/2020.
//  Copyright © 2020 Emily Blackwell. All rights reserved.
//

import Cocoa


fileprivate let nameID = SUID("nameCell")
fileprivate let countID = SUID("countCell")

extension ViewModel: NSTableViewDelegate, NSTableViewDataSource {
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		return self.document?.animations.count ?? 0
	}
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		
		guard let animation = self.document?.animations[row] else {
			return nil
		}
		
		let isName = (tableColumn?.identifier ?? SUID("")).rawValue == "name"
		let identifier = SUID((isName ? "name" : "count") + "Cell")
		let cell = tableView.makeView(withIdentifier: identifier, owner: nil) as! NSTableCellView
		
		cell.textField?.stringValue = isName ? animation.name : "\(animation.count)"
		return cell
	}
	
	func tableViewSelectionDidChange(_ notification: Notification) {
		
		let selectedRow = tableView.selectedRow
		
		guard selectedRow >= 0 && selectedRow < self.document.animations.count else {
			self.delegate?.clearPreview()
			return
		}
		
		let animation = self.document.animations[selectedRow]
		self.delegate?.previewAnimation(animation: animation)
	}
}
