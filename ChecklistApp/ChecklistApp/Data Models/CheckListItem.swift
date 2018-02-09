//
//  checkListItem.swift
//  ChecklistApp
//
//  Created by Christian on 2/5/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import UserNotifications

class CheckListItem: NSObject, Codable
{
    var text: String
    var checked: Bool
    
    var dueDate = Date()
    var shouldRemind = false
    var itemID: Int
    
    init(text: String, checked: Bool, shouldRemind: Bool, dueDate: Date) {
        
        self.text = text
        self.checked = checked
        self.shouldRemind = shouldRemind
        self.dueDate = dueDate
        itemID = AllListsViewController.nextChecklistItemID()
    }
    
    func scheduleNotification() {
        // 1
        let content = UNMutableNotificationContent()
        content.title = "Reminder:"
        content.body = text
        content.sound = UNNotificationSound.default()
        // 2
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents( [.month, .day, .hour, .minute], from: dueDate)
        // 3
        let trigger = UNCalendarNotificationTrigger( dateMatching: components, repeats: false)
        // 4
        let request = UNNotificationRequest(identifier: "\(itemID)", content: content, trigger: trigger)
        // 5
        let center = UNUserNotificationCenter.current()
        center.add(request)
        print("Scheduled: \(request) for itemID: \(itemID)")
    }
}
