//
//  checkListItem.swift
//  ChecklistApp
//
//  Created by Christian on 2/5/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

class CheckListItem: NSObject, Codable
{
    var text: String
    var checked: Bool
    
    var dueDate = Date()
    var shouldRemind = false
    var itemID: Int
    
    init(text: String, checked: Bool, shouldRemind: Bool, dueDate: Date) {
        
        self.text = text
        self.checked = checked
        itemID = AllListsViewController.nextChecklistItemID()
        
    }
    
    

}
