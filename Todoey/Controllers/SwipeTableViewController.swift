//
//  SwipeTableViewController.swift
//  Todoey
//
//  Created by Yick Ming Lee on 22/04/2021.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // get week number
    func getWeekNumber (date: Date) -> (weekNumber: Int?, yearForWeekOfYear: Int?) {
        let gregorian = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        gregorian.firstWeekday = 2 // Monday
        gregorian.minimumDaysInFirstWeek = 4
        
        let components =
            gregorian.components([NSCalendar.Unit.weekOfYear, NSCalendar.Unit.yearForWeekOfYear], from: date)
        let weekNumber = components.weekOfYear
        let yearForWeekOfYear = components.yearForWeekOfYear
        
        return (weekNumber, yearForWeekOfYear)
    }
    
    
    //MARK: - tableview datasource method
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /// also downcasting the cell as SwipeTableViewCell so that it has swipe property
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        
        cell.delegate = self
        
        return cell
    }
    
    
    
    //MARK: - cell swipe to left action -> delete

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            print("delete cell")
            self.handleMoveToTrash(at: indexPath)
        }
        
        let duplicateAction = SwipeAction(style: .default, title: "Copy") { action, indexPath in
            // handle action by updating model with deletion
            print("copy cell")
            self.handleDuplicate(at: indexPath)
        }
        
        let renameAction = SwipeAction(style: .default, title: "Rename") { action, indexPath in
            // handle action by updating model with deletion
            print("rename cell")
            self.handleRename(at: indexPath)
        }

        // customize the action appearance
        //deleteAction.image = UIImage(named: "delete-icon")

        return [deleteAction, renameAction, duplicateAction]
    }

    /// optional code 
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
//        options.expansionStyle = .destructive
        options.transitionStyle = .drag
        return options
    }
    
    
    func handleMoveToTrash(at indexPath: IndexPath) {
        // Update our data model. Config in sub class
    }
    
    func handleDuplicate(at indexPath: IndexPath) {
        // Update our data model. Config in sub class
    }
    
    func handleRename(at indexPath: IndexPath) {
        // Update our data model. Config in sub class
    }
    
}



