//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Yick Ming Lee on 25/03/2021.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift


class CategoryViewController: UITableViewController {
    
    let realm = try! Realm()
    
    /// Results data type in realm is whatever the result of your query is
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
    }
    
    /// MARK - save items into core data
    func save(category: Category) {
        /// store data
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving new category, \(error)")
        }
        
        /// refresh data
        tableView.reloadData()
    }
    
    // MARK - load items
    /// set default as fetch request
    func loadCategories() {
        
        categories = realm.objects(Category.self)
        
        tableView.reloadData()

    }
    
}

// MARK: - Table view data source
    
extension CategoryViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCategoryCell", for: indexPath)
        
        let category = categories?[indexPath.row].name ?? "No categories were loaded"
        
        cell.textLabel?.text = category
        
        return cell
    }
    
}

// MARK: - Table view add new category via alert
    
extension CategoryViewController {
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        /// show alert
        let alert = UIAlertController(title: "Add new Todoey category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            /// what will happen once the user clicks the add item butoon on our UIAlert.
            
            print(textField.text ?? "")
            
            let newCategory = Category()
            newCategory.name = textField.text!
            
            self.save(category: newCategory)
        }
        
        alert.addAction(action)
        
        alert.addTextField { (alertTextField) in
            textField = alertTextField
            alertTextField.placeholder = "Create new category"
        }
        
        present(alert, animated: true, completion: nil)
        
    }

}




//MARK: - cell selection action -> segue

extension CategoryViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        // could ask an "if" statement here to check if the segue has identify "goToItems". It's necessary if there were more than one segue.

        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row] 
        }
    }
    
}


//MARK: - cell swipe to left action -> delete

//extension CategoryViewController {
//
//    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//
//        /// Define delete action
//        let delete = UIContextualAction(style: .destructive,
//                                       title: "Trash") { [weak self] (action, view, completionHandler) in
//            self?.handleMoveToTrash(at: indexPath.row)
//                                        completionHandler(true)
//        }
//
//        /// Define color of button
//        delete.backgroundColor = .systemRed
//
//        let configuration = UISwipeActionsConfiguration(actions: [delete])
//        configuration.performsFirstActionWithFullSwipe = false
//
//        return configuration
//    }
//
//    private func handleMoveToTrash(at rowNumber: Int) {
//        print("Delete category")
//        context.delete(categoryArray[rowNumber])
//        categoryArray.remove(at: rowNumber)
//        saveCategories()
//    }
//
//}



