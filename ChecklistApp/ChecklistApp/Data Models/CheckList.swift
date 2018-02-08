//
//  CheckList.swift
//  ChecklistApp
//
//  Created by Christian on 2/6/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

class CheckList: NSObject, Codable {
    
    var name : String
    var iconName = "No Icon" //devices, locations, pokemon
    var items = [CheckListItem]()
    
    init(name: String, iconName: String = "No Icon")
    {
        self.name = name
        self.iconName = iconName
    }
    
    func addItem (checkListItem:CheckListItem)
    {
        items.append(checkListItem)
    }
    
    func countUncheckedItems() -> Int {
        
        var count = 0
        for item in items where !item.checked {
            count += 1
        }
        return count
    }
}
