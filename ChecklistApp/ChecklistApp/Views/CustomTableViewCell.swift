//
//  CustomTableViewCell.swift
//  ChecklistApp
//
//  Created by Christian on 2/5/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell
{
    //MARK:- variables
    var itemLabel = UILabel()
    var checkLabel = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //initialise views
        checkLabel.font = UIFont.boldSystemFont(ofSize: 22)
        
        itemLabel.text = "newItem"
        itemLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        // set views to use custome layout constraints
        checkLabel.translatesAutoresizingMaskIntoConstraints = false
        itemLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // add views to the main view
        contentView.addSubview(itemLabel)
        contentView.addSubview(checkLabel)
        
        //MARK:- layout constraints
        NSLayoutConstraint.activate(
            [
                checkLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20 ),
                checkLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                
                itemLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 50 ),
                itemLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

    

}
