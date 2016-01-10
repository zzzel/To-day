//
//  ViewController.swift
//  !procrastinate
//
//  Created by Zel Marko on 1/9/16.
//  Copyright © 2016 Zel Marko. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	@IBOutlet weak var tableView: UITableView!
	
	var tasks: [Task] = []
	var placeholderCell: TaskCell!
	var pullDownInProgress = false

	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 44.0
		placeholderCell = tableView.dequeueReusableCellWithIdentifier("TaskCell") as! TaskCell
		placeholderCell.backgroundColor = UIColor.blackColor()
		placeholderCell.titleLabel.textColor = UIColor.whiteColor()
		tasks = [
			Task(title: "Figure out how to add items"),
			Task(title: "What to use for Backend?!"),
			Task(title: "What happens if I put in a bit longer title for the task? Will it go to the next line? 🤔")
		]
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}

extension ViewController {
	func scrollViewWillBeginDragging(scrollView: UIScrollView) {
		pullDownInProgress = scrollView.contentOffset.y <= 0.0
		if pullDownInProgress {
			tableView.insertSubview(placeholderCell, atIndex: 0)
		}
	}
	func scrollViewDidScroll(scrollView: UIScrollView) {
		let scrollViewContentOffsetY = scrollView.contentOffset.y
		
		if pullDownInProgress && scrollView.contentOffset.y <= 0.0 {
			placeholderCell.frame = CGRect(x: 0, y: -44.0, width: tableView.frame.size.width, height: 44.0)
			placeholderCell.titleLabel.text = -scrollViewContentOffsetY > 44.0 ? "Release to add item" : "Pull to add task"
			placeholderCell.alpha = min(1.0, -scrollViewContentOffsetY / 44.0)
		} else {
			pullDownInProgress = false
		}
	}
	func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		if pullDownInProgress && -scrollView.contentOffset.y > 44.0 {
			// Add a new item
		}
		pullDownInProgress = false
		placeholderCell.removeFromSuperview()
	}
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tasks.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("TaskCell", forIndexPath: indexPath) as! TaskCell
		
		cell.delegate = self
		cell.task = tasks[indexPath.row]
		
		return cell
	}
}

extension ViewController: UITextViewDelegate {

	func textViewDidChange(textView: UITextView) {
		
		print(textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.max)))
//		let fixedWidth = textView.frame.size.width
//		textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
//		let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
//		
//		if newSize.height != descriptionTextViewConstraint.constant && newSize.height < 100 {
//			descriptionTextViewConstraint.constant = newSize.height
//			addFieldHeightConstraint.constant = newSize.height + 150
//			view.layoutIfNeeded()
//		}
	}
}

extension ViewController: TaskCellDelegate {
	
	func completeTask(task: Task) {
		print("Complete \(task.title)")
	}
	func deleteTask(task: Task) {
		print("Delete \(task.title)")
		let index = tasks.indexOf { $0.title == task.title }
		tasks.removeAtIndex(index!)
		tableView.beginUpdates()
		tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index!, inSection: 0)], withRowAnimation: .Right)
		tableView.endUpdates()
	}
}

