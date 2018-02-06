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

class ItemDetailsViewController: UITableViewController, UITextFieldDelegate
{
    //MARK:- variables
    private var itemNameCell: UITableViewCell = UITableViewCell()
    private var itemNameTextField: UITextField = UITextField()
    private var itemToEdit: CheckListItem?
    
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
        
        // custom cell initialisation
        self.itemNameTextField = UITextField(frame: self.itemNameCell.frame.insetBy(dx: 15, dy: 0))
        self.itemNameTextField.frame.insetBy( dx: 15, dy: 0)
        self.itemNameTextField.placeholder = "Name of the item"
        self.itemNameTextField.delegate = self
        self.itemNameCell.addSubview(self.itemNameTextField)
        
        // tableview initialisation
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //customise view based on wether you are adding or editing an item
        if let itemToEdit = self.itemToEdit
        {
            title = "Edit Item"
            itemNameTextField.text = itemToEdit.text
        }
        else
        {
            title = "Add Item"
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
        
        //set the text field to become active immediatly
        self.itemNameTextField.becomeFirstResponder()
    }
    
    @objc private func doneTapped(sender: UIButton)
    {
        // edit the checklist item
        if let itemToEdit = itemToEdit {
            itemToEdit.text = self.itemNameTextField.text!
            delegate?.itemDetailViewController(self, didFinishEditing: itemToEdit)
        }
        else // add the checklist item
        {
            let itemName = self.itemNameTextField.text
            let item = CheckListItem(text: itemName!, checked: false)
            delegate?.itemDetailViewController(self, didFinishAdding: item)
        }
    }
    
    @objc private func goBack(sender: UIButton)
    {
        delegate?.itemDetailViewControllerDidCancel(self)
    }
    
    //MARK:- tableview delegate methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView,
                           willSelectRowAt indexPath: IndexPath)
        -> IndexPath? {
            return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return self.itemNameCell
    }
    
    //Mark:- UITextField delegate methods
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let oldText = self.itemNameTextField.text!
        let stringRange = Range(range, in:oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        
        // enable the done button only if text field not empty
        navigationItem.rightBarButtonItem?.isEnabled = !newText.isEmpty
        
        return true
    }
 
}
