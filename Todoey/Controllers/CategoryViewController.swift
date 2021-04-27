//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Yick Ming Lee on 25/03/2021.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    /// Results data type in realm is whatever the result of your query is
    var categories: Results<Category>?
    
    /// get a set of items for duplicate category
    var todoItems: Results<Item>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        
        tableView.separatorStyle = .none
//        tableView.rowHeight = 50
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist.")}
        let navBarColor = UIColor.white
        navBar.backgroundColor = navBarColor
        navBar.barTintColor = navBarColor
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
        
    }


    
    // MARK: - save items into core data
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
    
    // MARK: - load items
    /// set default as fetch request
    func loadCategories() {
        
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    
    // MARK: - delete items
    override func handleMoveToTrash(at indexPath: IndexPath) {
        print("Delete item")
        if let categoryForDeletion = categories?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(categoryForDeletion)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
        }

        tableView.reloadData()
    }
    
    
    
    
    // MARK: - rename items
    override func handleRename(at indexPath: IndexPath) {
        print("Rename item")
        
        var textField = UITextField()
        
        /// show alert
        let alert = UIAlertController(title: "Rename Todoey category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Rename", style: .default) { (action) in
            /// what will happen once the user clicks the add item butoon on our UIAlert.
            
            print(textField.text ?? "")
            
            if let categoryForRename = self.categories?[indexPath.row] {
                do {
                    try self.realm.write {
                        categoryForRename.name = textField.text ?? ""
                        categoryForRename.updatedAt = Date()
                    }
                } catch {
                    print("Error renaming category, \(error)")
                }
            }
            
            self.tableView.reloadData()
        }
        
        alert.addAction(action)
        
        alert.addTextField { (alertTextField) in
            textField = alertTextField
            alertTextField.placeholder = "Rename category"
        }
        
        present(alert, animated: true, completion: nil)

    }
    
    
    // MARK: - duplicate items
    override func handleDuplicate(at indexPath: IndexPath) {
        print("Duplicate item")
        
        
        if let categoryForDup = categories?[indexPath.row] {
            do {
                try realm.write {
                    /// add a copy of the chosen category
                    let newCategory = Category()

                    if let weekNumber = getWeekNumber(date: Date()).weekNumber
                       , let yearForWeekOfYear = getWeekNumber(date: Date()).yearForWeekOfYear {
                        print(weekNumber)
                        print(yearForWeekOfYear)
                        
    //                    newCategory.name = categoryForDup.name + " (copy)"
                        newCategory.name = String(yearForWeekOfYear) + " Week #" + String(weekNumber)
                        newCategory.createdAt = Date()
                        newCategory.updatedAt = Date()
                        realm.add(newCategory)
                    }
                    
                    
                    /// add the not-done items from chosen category to the new copy
                    todoItems = categoryForDup.items.sorted(byKeyPath: "createdAt", ascending: true)
                    todoItems = todoItems?.filter("done != true")
                    
                    if let itemsToAdd = todoItems {
                        for newItem in itemsToAdd {
                            newCategory.items.append(newItem)
                        }
                    } else {
                        print("Error no to do itmes were available to be copied.")
                    }
                    
                    
                }
            } catch {
                print("Error duplicating category, \(error)")
            }
        }

        tableView.reloadData()
    }
    
    
}

// MARK: - Table view data source
    
extension CategoryViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /// #warning Incomplete implementation, return the number of rows
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /// get swipe cell from super class tableview
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        let category = categories?[indexPath.row].name ?? "No categories were loaded"
        
        cell.textLabel?.text = category
        
//        cell.backgroundColor = UIColor.randomFlat()

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
            newCategory.createdAt = Date()
            
            self.save(category: newCategory)
        }
        
        alert.addAction(action)
        
        alert.addTextField { (alertTextField) in
            textField = alertTextField
            alertTextField.placeholder = "Create new category"
            /// set default text in alertTextField, use week number
            if let weekNumber = self.getWeekNumber(date: Date()).weekNumber
               , let yearForWeekOfYear = self.getWeekNumber(date: Date()).yearForWeekOfYear {
                print(weekNumber)
                print(yearForWeekOfYear)
                alertTextField.text = String(yearForWeekOfYear) + " Week #" + String(weekNumber)
            }
            
        }
        
        present(alert, animated: true, completion: nil)
        
    }

}




//MARK: - cell selection action -> segue

extension CategoryViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        // could ask an "if" statement here to check if the segue has identify "goToItems". It's necessary if there were more than one segue.

        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
}





