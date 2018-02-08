//
//  AllListsViewController.swift
//  ChecklistApp
//
//  Created by Christian on 2/6/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

struct ListType {
    let empty = 0
    let inProgress = 1
    let done = 2
}

import UIKit

class AllListsViewController: UITableViewController, ListDetailViewControllerDelegate, UINavigationControllerDelegate
{
    //MARK:- variables
    private var filteredLists = [[CheckList](), [CheckList](), [CheckList]()]// array of checklist arrays
    private var allLists = [CheckList]()
    private let listType = ListType()
    // allLists[indexPath.section][indexPath.row]
    
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
//        listOfLists.append()
//        listOfLists.append(inProgressLists)
//        listOfLists.append(doneLists)
//        listOfLists.append(lists)
        
        
        //register for app will terminate notifications
        NotificationCenter.default.addObserver(self, selector: #selector(timeToSave), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(timeToSave), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)

        //nav bar initialisation
        title = "CheckLists"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target:self, action:#selector(openAddListDetailViewController))
        
        tableView.tableFooterView = UIView()
        
        loadCheckLists()
        registerDefaults()
        handleFirstTime()
        loadLastViewedList()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        filteredLists[listType.empty] = allLists.filter { $0.items.count == 0 } // set empty lists
        filteredLists[listType.inProgress] = allLists.filter({!filteredLists[listType.empty].contains($0) && $0.countUncheckedItems() > 0})
        filteredLists[listType.done] = allLists.filter( {!filteredLists[listType.empty].contains($0) && $0.countUncheckedItems() == 0})
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        indexOfSelectedChecklist = -1
    }
    
    // set default values for user defualts
    private func registerDefaults() {
        let dictionary: [String:Any] = [ "ChecklistIndex": -1,  "FirstLaunch": true, "ChecklistItemID": 0 ]
        UserDefaults.standard.register(defaults: dictionary)
       
    }
    
    // create new list on very first launch
    private func handleFirstTime()
    {
        if firstLaunch == true
        {
            let checklist = CheckList(name: "New List")
            allLists.append(checklist)
            indexOfSelectedChecklist = 0
            firstLaunch = false
        }
        
    }
    
    // check list index stored in user defaults to open last viewed list on launch
    private func loadLastViewedList()
    {
        if  indexOfSelectedChecklist >= 0 &&  indexOfSelectedChecklist < allLists.count{
            navigationController?.pushViewController(CheckListViewController(checkList: allLists[indexOfSelectedChecklist]), animated: false)
        }
    }
    
    @objc private func timeToSave()
    {
        saveCheckLists()
    }
    
    @objc private func openAddListDetailViewController(sender: UIBarButtonItem)
    {
        let listDetailViewController = ListDetailViewController(checkListToEdit: nil )
        listDetailViewController.delegate = self
        navigationController?.pushViewController(listDetailViewController, animated: true)
    }
    
    //static/ global function
    class func nextChecklistItemID() -> Int {
        let userDefaults = UserDefaults.standard
        let itemID = userDefaults.integer(forKey: "ChecklistItemID")
        userDefaults.set(itemID + 1, forKey: "ChecklistItemID")
        userDefaults.synchronize()
        return itemID
    }
    
    //MARK:- table view delegate methods
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = ""
        switch section
        {
            case 0:
                title = "Empty"
            case 1:
                title = "In Progress"
            case 2:
                title = "Done"
            default:
                title = "All Lists"
        }
        
        return title
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        //save checklist index into user defaults (used to launch app on last viewed checklist)
        indexOfSelectedChecklist =  indexPath.row
        
        navigationController?.pushViewController(CheckListViewController(checkList: filteredLists[indexPath.section][indexPath.row]), animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filteredLists[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell( withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        }
        
        let checkList = filteredLists[indexPath.section][indexPath.row]
        switch indexPath.section {
            case 0:
                cell?.detailTextLabel?.text = "none"
            case 1:
                cell?.detailTextLabel?.text = "\(checkList.countUncheckedItems()) Remaining"
            case 2:
                cell?.detailTextLabel!.text = "All Done!"
            default:
                cell?.detailTextLabel!.text = "All Lists"
        }
        
        cell?.textLabel!.text = checkList.name
        
        cell?.imageView!.image = UIImage(named: checkList.iconName)
        return cell!
    }
 
    
    //add edit buttons to table rows that appear on swipe
    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        //set up delete button functionality
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            print("share button tapped")
            //remove from filtered lists
            let listToDelete = self.filteredLists[editActionsForRowAt.section][editActionsForRowAt.row]
            self.allLists.removeElement(x: listToDelete)
            //remove from all lists
            self.filteredLists[editActionsForRowAt.section].remove(at: editActionsForRowAt.row)
            
            
            
            let indexPaths = [editActionsForRowAt]
            tableView.deleteRows(at: indexPaths, with: .automatic)
        }
        delete.backgroundColor = .red
        
        //set up edit button functionality
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            
            let editListViewController = ListDetailViewController(checkListToEdit: self.filteredLists[editActionsForRowAt.section][editActionsForRowAt.row])
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
        return documentsDirectory().appendingPathComponent("Checklists.plist")
    }
    
    private func saveCheckLists()
    {
        
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(allLists)
            try? data.write(to: dataFilePath(), options: Data.WritingOptions.atomic)
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
                allLists = try decoder.decode([CheckList].self, from: data)
                sortCheckLists()
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
        
        allLists.append(checklist)
        sortCheckLists()
        tableView.reloadData()
        navigationController?.popViewController(animated: true)
    }
    
    func listDetailViewController(_ controller: ListDetailViewController, didFinishEditing checklist: CheckList) {
        
        sortCheckLists()
        tableView.reloadData()
        navigationController?.popViewController(animated: true)
    }
    
    private func sortCheckLists() {
        allLists.sort(by: { checklist1, checklist2 in
            return checklist1.name.localizedStandardCompare(checklist2.name) == .orderedAscending })
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

extension Array where Element: Equatable {
    mutating func removeElement(x: Element) {
        if let i = self.index(of: x) {
            self.remove(at: i)
        }
    }
}
