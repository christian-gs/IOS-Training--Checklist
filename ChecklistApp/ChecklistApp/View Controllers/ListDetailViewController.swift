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

class textFieldCell : UITableViewCell
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

class IconCell: UITableViewCell
{
    var iconLabel: UILabel = UILabel()
    var iconImageView = UIImageView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.iconLabel.text = "Icon"
        self.iconImageView.image = UIImage()
        
        self.iconLabel.translatesAutoresizingMaskIntoConstraints = false
        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(iconLabel)
        contentView.addSubview(iconImageView)
        self.accessoryType = .disclosureIndicator
        
        NSLayoutConstraint.activate([
            iconLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            iconLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ListDetailViewController: UITableViewController,UITextFieldDelegate, IconPickerViewControllerDelegate
{
    
    //MARK:- variables
    private var checkListToEdit: CheckList?
    
    var iconName = ""
    var checkListName = ""
    
    weak var delegate: ListDetailViewControllerDelegate?

    
    init(checkListToEdit: CheckList? = nil)
    {
        self.checkListToEdit = checkListToEdit // if editing a list store the list for editing
        super.init(style: .grouped) // set tableview to use static cells
        
        // customise view for editing or adding a checklist
        if let checkListToEdit = self.checkListToEdit
        {
            title = "Edit CheckList"
            self.checkListName = checkListToEdit.name
            self.iconName = checkListToEdit.iconName
        }
        else
        {
            title = "Add CheckList"
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
        
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
        
        // initialise tableview
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(textFieldCell.self, forCellReuseIdentifier: "textFieldCell")
        tableView.register(IconCell.self, forCellReuseIdentifier: "iconCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

    }
    
    @objc func doneTapped(sender: UIButton)
    {
        // edit the checklist item
        if let checkListToEdit = checkListToEdit {
            checkListToEdit.name = self.checkListName
            checkListToEdit.iconName = self.iconName
            delegate?.listDetailViewController(self, didFinishEditing: checkListToEdit)
        }
        else // add the new checklist item
        {
            let checkListName = self.checkListName
            let checkList = CheckList(name: checkListName, iconName: self.iconName)
            delegate?.listDetailViewController(self, didFinishAdding: checkList)
        }
    }
    
    @objc func goBack(sender: UIButton)
    {
        delegate?.listDetailViewControllerDidCancel(self)
    }
    
    //Mark:- tableview delegate methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    //set itt so user can only click the second cell/ row
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var iconPickerViewController = IconPickerViewController()
        iconPickerViewController.delegate = self
        navigationController?.pushViewController(iconPickerViewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "textFieldCell", for: indexPath) as! textFieldCell
            cell.checkListNameTextField.becomeFirstResponder()
            cell.checkListNameTextField.delegate = self
            cell.checkListNameTextField.text = self.checkListName
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "iconCell", for: indexPath) as! IconCell
            cell.iconImageView.image = UIImage(named: self.iconName)
            return cell
        }
    }
    
    //MARK:- text field delegate methods
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let oldText = self.checkListName
        let stringRange = Range(range, in:oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        self.checkListName = newText
        
        // enable the done button only if text field not empty
        navigationItem.rightBarButtonItem?.isEnabled = !checkListName.isEmpty
        
        return true
    }
    
    //MARK:- iconPickerViewControllerDelegate methods
    func iconPicker(_ picker: IconPickerViewController, didPick iconName: String) {
        self.iconName = iconName
        tableView.reloadData()
        navigationController?.popViewController(animated: true)
    }
    
}

