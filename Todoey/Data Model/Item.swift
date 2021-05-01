//
//  Item.swift
//  Todoey
//
//  Created by Yick Ming Lee on 17/04/2021.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var createdAt: Date?
    @objc dynamic var updatedAt: Date?
    
    
    /// link to category
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
