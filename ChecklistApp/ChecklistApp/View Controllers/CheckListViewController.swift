//
//  ViewController.swift
//  ChecklistApp
//
//  Created by Christian on 2/5/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

class CheckListViewController: UITableViewController, ItemDetailsViewControllerDelegate
{
    // MARK:- variables
    private var checkList: CheckList
    
    // MARK:- custom constructor
    init(checkList: CheckList)
    {
        self.checkList = checkList
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // nav bar initialisation
        title = self.checkList.name
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target:self, action:#selector(openAddItemViewController))
        
        //tableview initialisation
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "ChecklistItem")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
    }
    
    @objc private func openAddItemViewController(sender: UIButton)
    {
        let addItemViewController = ItemDetailsViewController()
        addItemViewController.delegate = self
        navigationController?.pushViewController(addItemViewController, animated: true)
    }
    
    //MARK:- table view delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        checkList.items[indexPath.row].checked = !checkList.items[indexPath.row].checked
        
        if let cell = tableView.cellForRow(at: indexPath) as? CustomTableViewCell
        {
            updateCheckMark(index: indexPath.row ,cell: cell)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            print("share button tapped")
            
            self.checkList.items.remove(at: editActionsForRowAt.row)
            let indexPaths = [editActionsForRowAt]
            tableView.deleteRows(at: indexPaths, with: .automatic)
        }
        delete.backgroundColor = .red
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            
            let addItemViewController = ItemDetailsViewController(itemToEdit: self.checkList.items[editActionsForRowAt.row])
            addItemViewController.delegate = self
            self.navigationController?.pushViewController(addItemViewController, animated: true)
        }
        edit.backgroundColor = .lightGray
        
       
        
        return [delete, edit]
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checkList.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell( withIdentifier: "ChecklistItem", for: indexPath) as? CustomTableViewCell

        
        cell?.itemLabel.text = checkList.items[indexPath.row].text
        updateCheckMark(index: indexPath.row, cell: cell!)
        
        
        return cell!
        
    }
    
    private func updateCheckMark(index: Int, cell: CustomTableViewCell)
    {
        if self.checkList.items[index].checked{
            cell.checkLabel.text = "✔️"
        }
        else{
            cell.checkLabel.text = ""
        }
    }
    
    
    
    //MARK:- addItemViewController delegate methods
    
    func itemDetailViewControllerDidCancel(
        _ controller: ItemDetailsViewController)
    {
        navigationController?.popViewController(animated:true)
    }
    func itemDetailViewController(_ controller: ItemDetailsViewController,didFinishAdding item: CheckListItem)
    {
        checkList.items.append(item)
        tableView.reloadData()
        
        navigationController?.popViewController(animated:true)
    }
    
    func itemDetailViewController(_ controller: ItemDetailsViewController, didFinishEditing item: CheckListItem)
    {
        if let index = checkList.items.index(of: item)
        {
            checkList.items[index] = item
        }
        tableView.reloadData()
        
        navigationController?.popViewController(animated:true)
    }



}

