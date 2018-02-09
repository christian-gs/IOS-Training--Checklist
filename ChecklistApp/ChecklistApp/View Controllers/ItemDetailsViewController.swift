//
//  addItemViewController.swift
//  ChecklistApp
//
//  Created by Christian on 2/5/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import UserNotifications

//MARK:- ItemDetailsViewControllerDelegate
protocol ItemDetailsViewControllerDelegate: class
{
    func itemDetailViewControllerDidCancel(_ controller: ItemDetailsViewController)
    func itemDetailViewController(_ controller: ItemDetailsViewController, didFinishAdding item: CheckListItem)
    func itemDetailViewController(_ controller: ItemDetailsViewController, didFinishEditing item: CheckListItem)
}

class ItemDetailsViewController: UITableViewController, UITextFieldDelegate
{
    //MARK:- variables
    private var itemToEdit: CheckListItem?
    var itemName = ""
    var remindSwitchState = false
    var dueDate = Date()
    var datePickerVisible = false
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
        tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: "textFieldCell")
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: "switchCell")
        tableView.register(DoubleLabelTableViewCell.self, forCellReuseIdentifier: "doubleLabelCell")
        tableView.register(DatePickerTableViewCell.self, forCellReuseIdentifier: "datePickerCell")
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
            itemToEdit.handleNotification()
            delegate?.itemDetailViewController(self, didFinishEditing: itemToEdit)
        }
        else // add the checklist item
        {
            let item = CheckListItem(text: itemName, checked: false, shouldRemind: remindSwitchState, dueDate: self.dueDate)
            item.handleNotification()
            delegate?.itemDetailViewController(self, didFinishAdding: item)
        }
    }
    
    @objc private func goBack(sender: UIButton)
    {
        delegate?.itemDetailViewControllerDidCancel(self)
    }
    
    func toggleDatePickerVisibility() {
        self.datePickerVisible = !self.datePickerVisible
        if datePickerVisible {
            tableView.insertRows(at: [IndexPath(row: 2, section: 1)], with: .top)
        } else {
            tableView.deleteRows(at: [IndexPath(row: 2, section: 1)], with: .automatic)
        }
    }
    
    func shouldRemindToggled(switchState: Bool) {
        if switchState{
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound]) {
                granted, error in
                
            }
        }
        self.remindSwitchState = switchState
    }
    
    //MARK:- tableview delegate methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }
        else if section == 1 && datePickerVisible {
            return 3
        }
        else {
            return 2
        }
    }
    
    // adjust cell height for date picker hieght (return default height for other cells)
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 2 {
            return 217
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    //make date picker cell tapable (and the other cells untappable)
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 1 && indexPath.row == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //textField.resignFirstResponder()
        if indexPath.section == 1 && indexPath.row == 1 {
            toggleDatePickerVisibility()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if  indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "textFieldCell", for: indexPath) as! TextFieldTableViewCell
            cell.checkListNameTextField.becomeFirstResponder()
            cell.checkListNameTextField.delegate = self
            cell.checkListNameTextField.text = self.itemName
            return cell
        }
        else if indexPath.section == 1 && indexPath.row == 2 && datePickerVisible {
            let cell = tableView.dequeueReusableCell(withIdentifier: "datePickerCell", for: indexPath) as! DatePickerTableViewCell
            cell.datePicker.setDate(dueDate, animated: false)
            cell.handler = {
                self.dueDate = $0
                self.tableView.reloadData()
                
            }
            return cell
        }
        else {
            if indexPath.row == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell", for: indexPath) as! SwitchTableViewCell
                cell.reminderSwitch.isOn = self.remindSwitchState
                cell.handler = self.shouldRemindToggled
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "doubleLabelCell", for: indexPath) as! DoubleLabelTableViewCell
    
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .short
                cell.rightLabel.text = formatter.string(from: dueDate)
                cell.rightLabel.textColor = self.datePickerVisible ? navigationController?.navigationBar.tintColor : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                
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
