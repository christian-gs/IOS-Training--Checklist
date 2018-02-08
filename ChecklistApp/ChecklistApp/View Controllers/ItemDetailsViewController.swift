//
//  addItemViewController.swift
//  ChecklistApp
//
//  Created by Christian on 2/5/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

//MARK:- ItemDetailsViewControllerDelegate
protocol ItemDetailsViewControllerDelegate: class
{
    func itemDetailViewControllerDidCancel(_ controller: ItemDetailsViewController)
    func itemDetailViewController(_ controller: ItemDetailsViewController, didFinishAdding item: CheckListItem)
    func itemDetailViewController(_ controller: ItemDetailsViewController, didFinishEditing item: CheckListItem)
}

class SwitchCell: UITableViewCell
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

class DoubleLabelCell: UITableViewCell
{
    var leftLabel = UILabel()
    var rightLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.leftLabel.text = "Due Date"
        self.rightLabel.text = "Detail"
        
        for label in [leftLabel, rightLabel] {
            label.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(label)
        }
        
        NSLayoutConstraint.activate([
            leftLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            leftLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rightLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            rightLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ItemDetailsViewController: UITableViewController, UITextFieldDelegate
{
    //MARK:- variables
    private var itemToEdit: CheckListItem?
    var itemName = ""
    var remindSwitchState = false
    var dueDate = Date()
    weak var delegate: ItemDetailsViewControllerDelegate?

    init(itemToEdit: CheckListItem? = nil)
    {
        self.itemToEdit = itemToEdit // if editing an item store the item for editing
        super.init(style: .grouped) // set table view to use static cells (the amount of rows will not change)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //nav bar initialisation
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target:self, action:#selector(goBack))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target:self, action:#selector(doneTapped))
        
        // tableview initialisation
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: "textFieldCell")
        tableView.register(SwitchCell.self, forCellReuseIdentifier: "switchCell")
        tableView.register(DoubleLabelCell.self, forCellReuseIdentifier: "doubleLabelCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //customise view based on wether you are adding or editing an item
        if let itemToEdit = self.itemToEdit
        {
            title = "Edit Item"
            itemName = itemToEdit.text
            remindSwitchState = itemToEdit.shouldRemind
            dueDate = itemToEdit.dueDate
        }
        else
        {
            title = "Add Item"
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    @objc private func doneTapped(sender: UIButton)
    {
        // edit the checklist item
        if let itemToEdit = itemToEdit {
            itemToEdit.text = itemName
            itemToEdit.shouldRemind = self.remindSwitchState
            itemToEdit.dueDate = self.dueDate
            delegate?.itemDetailViewController(self, didFinishEditing: itemToEdit)
        }
        else // add the checklist item
        {
            let item = CheckListItem(text: itemName, checked: false, shouldRemind: remindSwitchState, dueDate: self.dueDate)
            delegate?.itemDetailViewController(self, didFinishAdding: item)
        }
    }
    
    @objc private func goBack(sender: UIButton)
    {
        delegate?.itemDetailViewControllerDidCancel(self)
    }
    

    
    //MARK:- tableview delegate methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rowCount = section == 0 ? 1 : 2
        return rowCount
    }

    override func tableView(_ tableView: UITableView,
                           willSelectRowAt indexPath: IndexPath)
        -> IndexPath? {
            return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "textFieldCell", for: indexPath) as! TextFieldCell
                cell.checkListNameTextField.becomeFirstResponder()
                cell.checkListNameTextField.delegate = self
                cell.checkListNameTextField.text = self.itemName
                return cell
            default:
                if indexPath.row == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell", for: indexPath) as! SwitchCell
                    cell.reminderSwitch.isOn = self.remindSwitchState
                    cell.handler = { self.itemToEdit?.shouldRemind = $0}
                    return cell
                }
                else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "doubleLabelCell", for: indexPath) as! DoubleLabelCell
                    
                    let formatter = DateFormatter()
                    formatter.dateStyle = .medium
                    formatter.timeStyle = .short
                    cell.rightLabel.text = formatter.string(from: dueDate)
                    
                    
                    return cell
                }
            
        }
    }

    
    //Mark:- UISwitch delegate methods
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let oldText = itemName
        let stringRange = Range(range, in:oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        itemName = newText
        
        // enable the done button only if text field not empty
        navigationItem.rightBarButtonItem?.isEnabled = !newText.isEmpty
        
        return true
    }
 
}
