//
//  AllListsViewController.swift
//  ChecklistApp
//
//  Created by Christian on 2/6/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

class AllListsViewController: UITableViewController, ListDetailViewControllerDelegate, UINavigationControllerDelegate
{
    //MARK:- variables
    private var lists = [CheckList]()
    
    //MARK:- properties
    private var indexOfSelectedChecklist: Int
    {
        get {
            return UserDefaults.standard.integer(forKey: "ChecklistIndex")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "ChecklistIndex")
            UserDefaults.standard.synchronize()
        }
    }
    
    private var firstLaunch: Bool
    {
        get {
            return UserDefaults.standard.bool(forKey: "FirstLaunch")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "FirstLaunch")
            UserDefaults.standard.synchronize()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(" \n\n\n Documents folder is \(documentsDirectory()) \n\n\n\n")
        print("\n\n Data file path is \(dataFilePath()) \n\n\n\n")
        
        //register for app will terminate notifications
        NotificationCenter.default.addObserver(self, selector: #selector(timeToSave), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(timeToSave), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)

        //nav bar initialisation
        title = "CheckLists"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target:self, action:#selector(openAddListDetailViewController))
        
        loadCheckLists()
        registerDefaults()
        handleFirstTime()
        loadLastViewedList()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        indexOfSelectedChecklist = -1
    }
    
    // set default values for user defualts
    private func registerDefaults() {
        let dictionary: [String:Any] = [ "ChecklistIndex": -1,  "FirstLaunch": true ]
        UserDefaults.standard.register(defaults: dictionary)
       
    }
    
    // create new list on very first launch
    private func handleFirstTime()
    {
        if firstLaunch == true
        {
            let checklist = CheckList(name: "New List")
            lists.append(checklist)
            indexOfSelectedChecklist = 0
            firstLaunch = false
        }
        
    }
    
    // check list index stored in user defaults to open last viewed list on launch
    private func loadLastViewedList()
    {
        if  indexOfSelectedChecklist >= 0 &&  indexOfSelectedChecklist < lists.count{
            navigationController?.pushViewController(CheckListViewController(checkList: lists[ indexOfSelectedChecklist]), animated: false)
        }
    }
    
    @objc private func timeToSave()
    {
        saveCheckLists()
    }
    
    @objc private func openAddListDetailViewController(sender: UIBarButtonItem)
    {
        var listDetailViewController = ListDetailViewController(checkListToEdit: nil )
        listDetailViewController.delegate = self
        navigationController?.pushViewController(listDetailViewController, animated: true)
    }
    
    //MARK:- table view delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        //save checklist index into user defaults (used to launch app on last viewed checklist)
        indexOfSelectedChecklist =  indexPath.row
        
        navigationController?.pushViewController(CheckListViewController(checkList: lists[indexPath.row]), animated: true)
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return lists.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = makeCell(for: tableView)
        cell.textLabel!.text = lists[indexPath.row].name
        return cell
    }
 
    // make cells from scratch
    func makeCell(for tableView: UITableView) -> UITableViewCell
    {
        let cellIdentifier = "Cell"
        //try and re-use existing cell
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        {
            return cell
        } else {
            // return new cell if theres none to re-use
            return UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        
    }
    
    //add edit buttons to table rows that appear on swipe
    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        //set up delete button functionality
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            print("share button tapped")
            
            self.lists.remove(at: editActionsForRowAt.row)
            let indexPaths = [editActionsForRowAt]
            tableView.deleteRows(at: indexPaths, with: .automatic)
        }
        delete.backgroundColor = .red
        
        //set up edit button functionality
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            
            let editListViewController = ListDetailViewController(checkListToEdit: self.lists[editActionsForRowAt.row])
            editListViewController.delegate = self
            self.navigationController?.pushViewController(editListViewController, animated: true)
        }
        edit.backgroundColor = .lightGray
        
        // add new buttons to table rows
        return [delete, edit]
    }

    
    //MARK:- data persistance (saving)
    
    // func for accessing apps local documents folder
    private func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    //func to create/access new file which will be used to store data to
    private func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent( "Checklists.plist")
    }
    
    private func saveCheckLists()
    {
        
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(lists)
            try data.write(to: dataFilePath(), options: Data.WritingOptions.atomic)
        }
        catch {
            print("Error encoding item array!")
        }
        
    }
    
    private func loadCheckLists()
    {
        
        let path = dataFilePath()
        if let data = try? Data(contentsOf: path)
        {
            let decoder = PropertyListDecoder()
            do {
                lists = try decoder.decode([CheckList].self, from: data)
            }
            catch {
                print("Error decoding item array!")
            }
        }
        
    }
    
    //MARK:- listDetailViewControllerDelegate methods
    func listDetailViewControllerDidCancel(_ controller: ListDetailViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func listDetailViewController(_ controller: ListDetailViewController, didFinishAdding checklist: CheckList) {
        
        lists.append(checklist)
        tableView.reloadData()
        
        navigationController?.popViewController(animated: true)
    }
    
    func listDetailViewController(_ controller: ListDetailViewController, didFinishEditing checklist: CheckList) {
        
        tableView.reloadData()
        navigationController?.popViewController(animated: true)
    }
    
    //MARK:- UINavigationController delegate methods
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // Was the back button tapped?
        if viewController === self
        {
            indexOfSelectedChecklist = -1 // update checklist index into user defaults (using property)
        }
    }

}
