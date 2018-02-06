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
    var text: String = ""
    var checked: Bool = false
    
    init(text: String, checked: Bool) {
        
        self.text = text
        self.checked = checked
        
    }
    
    

}
