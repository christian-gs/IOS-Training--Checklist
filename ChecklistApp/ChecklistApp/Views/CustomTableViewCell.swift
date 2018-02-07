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
    var checkImageView = UIImageView()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //initialise views
        itemLabel.text = "newItem"
        itemLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        checkImageView.translatesAutoresizingMaskIntoConstraints = false
        itemLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(checkImageView)
        contentView.addSubview(itemLabel)
        
        //MARK:- layout constraints
        NSLayoutConstraint.activate(
            [
                checkImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20 ),
                checkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                
                itemLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 50 ),
                itemLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

    

}
