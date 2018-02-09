//
//  TextFieldTableViewCell.swift
//  ChecklistApp
//
//  Created by Christian on 2/8/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

class TextFieldTableViewCell : UITableViewCell
{
    var checkListNameTextField: UITextField!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // initialise cutom cells
        self.checkListNameTextField = UITextField(frame: self.frame.insetBy(dx: 15, dy: 0))
        self.checkListNameTextField.frame.insetBy( dx: 15, dy: 0)
        self.checkListNameTextField.placeholder = "Name of the item"
        contentView.addSubview(self.checkListNameTextField)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
