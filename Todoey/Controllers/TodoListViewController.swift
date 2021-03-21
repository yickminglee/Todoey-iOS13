//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {

    var itemArray = [Item]()
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    /// Shared singleton object -> Current app is an object. delegate is the AppDelegate. Then we downcast it as AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Do any additional setup after loading the view.
        /// check data file path
        print(dataFilePath.absoluteString)
        
        loadItems()
    }
    
    /// MARK - save items into plist
    func saveItems() {
        /// store data
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
        /// refresh data
        tableView.reloadData()
    }
    
    // MARK - load items
    /// set default as fetch request
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest()) {
        do {
            /// fetch data. table view data source will then pick this up
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        tableView.reloadData()
        
    }
    
}


//MARK: - Extension: search bar methods

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print(searchBar.text!)
        
        /// define the datatype of request, and address a value => load it onto view
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)

        let sortDescriptorByTitle = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortDescriptorByTitle]
        
        loadItems(with: request)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
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
            let newItem = Item(context: self.context)
            
            newItem.title = textField.text!
            newItem.done = false

            self.itemArray.append(newItem)

            /// store data - seems that it doesn't work well with user-defined class
//            self.defaults.set(self.itemArray, forKey: "TodoListArray")
            
            self.saveItems()
        }
        
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
//        print(itemArray[indexPath.row])
        
        /// toggle "done" in array
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

//MARK: - cell swipe to left action -> delete

extension TodoListViewController {
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        /// Define delete action
        let delete = UIContextualAction(style: .destructive,
                                       title: "Trash") { [weak self] (action, view, completionHandler) in
            self?.handleMoveToTrash(at: indexPath.row)
                                        completionHandler(true)
        }
        
        /// Define color of button
        delete.backgroundColor = .systemRed
        
        let configuration = UISwipeActionsConfiguration(actions: [delete])
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }
    
    private func handleMoveToTrash(at rowNumber: Int) {
        print("Delete item")
        context.delete(itemArray[rowNumber])
        itemArray.remove(at: rowNumber)
        saveItems()
    }
    
}



//MARK: - table view data source set up

extension TodoListViewController {
    /// define n rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    /// define row content
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let message = itemArray[indexPath.row].title
        let status = itemArray[indexPath.row].done
        
        cell.textLabel?.text = message
        
        /// Ternary operator =>
        /// value = condition ? valueIfTrue : valueIfFalse
        cell.accessoryType = status ? .checkmark : .none
        
        
        return cell
    }
}
