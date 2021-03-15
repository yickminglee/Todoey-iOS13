//
//  Item.swift
//  Todoey
//
//  Created by Yick Ming Lee on 11/03/2021.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation

class Item: Codable { /// conform to both encodable and decodable
    var title: String = ""
    var done: Bool = false
}



