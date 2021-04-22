//
//  Category.swift
//  Todoey
//
//  Created by Yick Ming Lee on 17/04/2021.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    let items = List<Item>() // List is Realm's version of array
}
