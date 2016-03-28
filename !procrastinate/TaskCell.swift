//
//  TaskCell.swift
//  !procrastinate
//
//  Created by Zel Marko on 1/9/16.
//  Copyright © 2016 Zel Marko. All rights reserved.
//

import UIKit

protocol TaskCellDelegate {
	func completeTask(task: Task)
	func deleteTask(task: Task)
}

class TaskCell: UITableViewCell {
	
	@IBOutlet weak var titleTextView: UITextView!
	
	var delegate: TaskCellDelegate?
	var task: Task! {
		didSet {
			strikesthroghOrNot()
		}
	}
	
	var originalCenter = CGPoint()
	var markComplete = false, delete = false
	let slide = SlideView()
	var stageView: UIView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		stageView = slide.view
		
		titleTextView.textContainerInset = UIEdgeInsetsZero
		titleTextView.textContainer.lineFragmentPadding = 0.0
		
		let recognizer = UIPanGestureRecognizer(target: self, action: #selector(TaskCell.handlePan(_:)))
		addGestureRecognizer(recognizer)
		recognizer.delegate = self
	}
	
	func handlePan(recognizer: UIPanGestureRecognizer) {
		if recognizer.state == .Began {
			originalCenter = center
		}
		if recognizer.state == .Changed {
			let translation = recognizer.translationInView(self)
			center = CGPointMake(originalCenter.x + translation.x, originalCenter.y)
			stageView.center = CGPointMake((originalCenter.x - frame.width) + translation.x, stageView.center.y)
			markComplete = frame.origin.x > 0.0 && frame.origin.x < (frame.size.width / 4.0) * 3
			if markComplete {
				stageView.backgroundColor = UIColor.greenColor()
			}
			delete = frame.origin.x > (frame.size.width / 4.0) * 3
			if delete {
				stageView.backgroundColor = UIColor.redColor()
			}
		}
		if recognizer.state == .Ended {
			if markComplete {
				if let delegate = delegate {
					task.completed = !task.completed
					delegate.completeTask(task)
					strikesthroghOrNot()
				}
				resetFrame()
				markComplete = false
			} else if delete {
				if let delegate = delegate {
					delegate.deleteTask(task)
					UIView.animateWithDuration(0.2, animations: {
						self.stageView.alpha = 0.0
						}, completion: { _ in
							self.stageView.removeFromSuperview()
					})
				}
			} else {
				resetFrame()
			}
		}
	}
	
	func resetFrame() {
		let originalFrame = CGRect(x: 0, y: frame.origin.y, width: bounds.size.width, height: bounds.size.height)
		UIView.animateWithDuration(0.2, animations: { () -> Void in
			self.frame = originalFrame
			}, completion: { _ in
				self.stageView.removeFromSuperview()
				self.stageView.backgroundColor = UIColor.whiteColor()
		})
	}
	
	func strikesthroghOrNot() {
		if task.completed {
			let strikethroughString = NSAttributedString(string: task.title, attributes: [NSStrikethroughStyleAttributeName: 1, NSFontAttributeName: UIFont.systemFontOfSize(18, weight: UIFontWeightUltraLight)])
			titleTextView.attributedText = strikethroughString
		} else {
			let regularString = NSAttributedString(string: task.title, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(18, weight: UIFontWeightMedium)])
			titleTextView.attributedText = regularString
		}
	}
	
	override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
		if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
			let translation = panGestureRecognizer.translationInView(superview!)
			if fabs(translation.x) > fabs(translation.y) {
				stageView.frame = CGRect(x: -frame.origin.x, y: frame.origin.y, width: bounds.size.width, height: bounds.size.height)
				superview!.insertSubview(stageView, belowSubview: self)
				return true
			}
			return false
		}
		return false
	}
}
