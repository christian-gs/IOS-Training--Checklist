//
//  switchTableViewCell.swift
//  ChecklistApp
//
//  Created by Christian on 2/9/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

class SwitchTableViewCell: UITableViewCell
{
    var switchLabel: UILabel = UILabel()
    var reminderSwitch = UISwitch()
    
    var handler: ((Bool) -> Void)?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.switchLabel.text = "Remind Me"
        
        self.switchLabel.translatesAutoresizingMaskIntoConstraints = false
        self.reminderSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        reminderSwitch.addTarget(self, action: #selector(switchStateChanged(sender:)), for: .valueChanged)
        
        contentView.addSubview(switchLabel)
        contentView.addSubview(reminderSwitch)
        
        NSLayoutConstraint.activate([
            switchLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            switchLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            reminderSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            reminderSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
    }
    
    @objc func switchStateChanged(sender: UISwitch) {
        handler?(sender.isOn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

