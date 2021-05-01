//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var todoItems: Results<Item>?
    
    var selectedCategory: Category? {
        // when category is set, do loadItems
        didSet{
            loadItems()
        }
    }
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Do any additional setup after loading the view.
        /// check data file path
        print(dataFilePath.absoluteString)
        
        tableView.separatorStyle = .none
        
        loadItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist.")}
        
        title = selectedCategory!.name
        
        let navBarColor = UIColor.white
        navBar.backgroundColor = navBarColor
        navBar.barTintColor = navBarColor
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
        
        searchBar.barTintColor = navBarColor
    }
    

    // MARK: - load items
    /// set default as fetch request
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "updatedAt", ascending: true)
        tableView.reloadData()
    }
    
    
    // MARK: - delete items
    /// set default as fetch request
    override func handleMoveToTrash(at indexPath: IndexPath) {
        print("Delete item")
        if let itemForDeletion = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(itemForDeletion)
                }
            } catch {
                print("Error deleting item, \(error)")
            }
        }

        tableView.reloadData()
    }
    
    
    // MARK: - rename items
    override func handleRename(at indexPath: IndexPath) {
        print("Rename item")
        
        var textField = UITextField()
        
        /// show alert
        let alert = UIAlertController(title: "Rename Todoey item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Rename", style: .default) { (action) in
            /// what will happen once the user clicks the add item butoon on our UIAlert.
            
            print(textField.text ?? "")
            
            if let itemForRename = self.todoItems?[indexPath.row] {
                do {
                    try self.realm.write {
                        itemForRename.title = textField.text ?? ""
                    }
                } catch {
                    print("Error renaming item, \(error)")
                }
            }
            
            self.tableView.reloadData()
        }
        
        alert.addAction(action)
        
        alert.addTextField { (alertTextField) in
            textField = alertTextField
            alertTextField.placeholder = "Rename item"
        }
        
        present(alert, animated: true, completion: nil)

    }
    
    // MARK: - copy items
    override func handleDuplicate(at indexPath: IndexPath) {
        print("Duplicate item")
        
        if let currentCategory = self.selectedCategory {
            
            if let itemForDup = todoItems?[indexPath.row] {
                do {
                    try realm.write {
                        /// add a copy of the chosen category
                        let newItem = Item()
                            
                        newItem.title = itemForDup.title + " (copy)"
                        newItem.createdAt = Date()
                        newItem.updatedAt = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error duplicating item, \(error)")
                }
            }
            tableView.reloadData()
        }
        
    }
    
    
}




//MARK: - Extension: search bar methods

extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print(searchBar.text!)
        
        /// define the datatype of request, and address a value => load it onto view
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "createdAt", ascending: true)
        
        tableView.reloadData()

    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        /// when we dismiss the search bar
        if searchBar.text?.count == 0 {
            loadItems()

            /// Task manager to assign this task to main thread (expedite this task)
            DispatchQueue.main.async {
                /// dismiss keyboard and cursor
                searchBar.resignFirstResponder()
            }

        }
    }

}




//MARK: - Extension: add item via alert

extension TodoListViewController {
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        /// show alert
        let alert = UIAlertController(title: "Add new Todoey item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            /// what will happen once the user clicks the add item butoon on our UIAlert.
            
            print(textField.text ?? "")
            
            // unwrap selectedCategory first
            if let currentCategory = self.selectedCategory {
                
                do {
                    /// add and store data
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.createdAt = Date()
                        newItem.updatedAt = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new items, \(error)")
                }
            }
            
            self.tableView.reloadData()
            
        } // end of closure
        
        
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
}


//MARK: - cell selection action -> done / undone

extension TodoListViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(todoItems![indexPath.row])
        
        /// toggle "done" in array
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                    item.updatedAt = Date()
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
        
        tableView.reloadData()
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}





//MARK: - table view data source set up

extension TodoListViewController {
    /// define n rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    /// define row content
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /// get swipe cell from super class tableview
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            let message = item.title
            let status = item.done

            cell.textLabel?.text = message

            /// Ternary operator =>
            /// value = condition ? valueIfTrue : valueIfFalse
            cell.accessoryType = status ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items can be found"
        }
        
        return cell
    }
}

//MARK: - cell swipe to left action -> delete

//extension TodoListViewController {
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
//        print("Delete item")
//        if let item = todoItems?[rowNumber] {
//            do {
//                try realm.write {
//                    realm.delete(item)
//                }
//            } catch {
//                print("Error deleting item, \(error)")
//            }
//        }
//
//        tableView.reloadData()
//
//    }
//
//}
