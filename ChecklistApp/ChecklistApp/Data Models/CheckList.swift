//
//  CheckList.swift
//  ChecklistApp
//
//  Created by Christian on 2/6/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

class CheckList: NSObject, Codable {
    
    var name = ""
    var items = [CheckListItem]()
    
    init(name: String)
    {
        self.name = name
    }
    
    func addItem (checkListItem:CheckListItem)
    {
        items.append(checkListItem)
    }

}
