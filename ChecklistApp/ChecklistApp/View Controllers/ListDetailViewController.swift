//
//  ListDetailViewController.swift
//  ChecklistApp
//
//  Created by Christian on 2/6/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit


protocol ListDetailViewControllerDelegate: class
{
    func listDetailViewControllerDidCancel(_ controller: ListDetailViewController)
    func listDetailViewController(_ controller: ListDetailViewController, didFinishAdding checklist: CheckList)
    func listDetailViewController(_ controller: ListDetailViewController, didFinishEditing checklist: CheckList)
}

class ListDetailViewController: UITableViewController,UITextFieldDelegate
{
    //MARK:- variables
    private var checkListNameCell: UITableViewCell = UITableViewCell()
    private var checkListNameTextField: UITextField!
    private var checkListToEdit: CheckList?
    
    weak var delegate: ListDetailViewControllerDelegate?

    
    init(checkListToEdit: CheckList? = nil)
    {
        self.checkListToEdit = checkListToEdit // if editing a list store the list for editing
        super.init(style: .grouped) // set tableview to use static cells
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // intialise navigation bar
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target:self, action:#selector(goBack))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target:self, action:#selector(doneTapped))
        
        // initialise cutom cells
        self.checkListNameTextField = UITextField(frame: self.checkListNameCell.frame.insetBy(dx: 15, dy: 0))
        self.checkListNameTextField.frame.insetBy( dx: 15, dy: 0)
        self.checkListNameTextField.placeholder = "Name of the item"
        self.checkListNameTextField.delegate = self
        self.checkListNameCell.addSubview(self.checkListNameTextField)
        
        // initialise tableview
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // customise view for editing or adding a checklist
        if let checkListToEdit = self.checkListToEdit
        {
            title = "Edit CheckList"
            checkListNameTextField.text = checkListToEdit.name
        }
        else
        {
            title = "Add CheckList"
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
        
        // set textfield to become active imm editalty
        self.checkListNameTextField.becomeFirstResponder()
    }
    
    @objc func doneTapped(sender: UIButton)
    {
        // edit the checklist item
        if let checkListToEdit = checkListToEdit {
            checkListToEdit.name = self.checkListNameTextField.text!
            delegate?.listDetailViewController(self, didFinishEditing: checkListToEdit)
        }
        else // add the new checklist item
        {
            let checkListName = self.checkListNameTextField.text
            let checkList = CheckList(name: checkListName!)
            delegate?.listDetailViewController(self, didFinishAdding: checkList)
        }
    }
    
    @objc func goBack(sender: UIButton)
    {
        delegate?.listDetailViewControllerDidCancel(self)
    }
    
    //Mark:- tableview delegate methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath)
        -> IndexPath? {
            return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return self.checkListNameCell
    }
    
    //MARK:- text field delegate methods
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let oldText = self.checkListNameTextField.text!
        let stringRange = Range(range, in:oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        
        // enable the done button only if text field not empty
        navigationItem.rightBarButtonItem?.isEnabled = !newText.isEmpty
        
        return true
    }
    
}

