//
//  ReminderDetailView.swift
//  Xpense
//
//  Created by Teddy Santya on 4/11/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI
import Firebase

struct ReminderDetailView: View {
    @Binding var reminderDate: Date
    @Binding var reminderEnabled: Bool
    var notificationName: String
    var cardName: String
    
    @ObservedObject var settings = UserSettings()
    var body: some View {
        VStack {
            Text("Reminder")
            VStack(spacing: .medium) {
                Toggle(isOn: $reminderEnabled, label: {
                    Text("Enable Reminder")
                })
                DatePicker("Date & Time", selection: $reminderDate)
            }.padding()
            .frame(minHeight: 150)
            .onAppear {
                Analytics.logEvent(AnalyticsEventScreenView, parameters:[
                    "screenName": "Reminder Detail"
                ])
            }
            .onChange(of: reminderEnabled, perform: { value in
                cancelExistingReminder()
                if value {
                    createReminderNotification()
                }
            })
            .onChange(of: reminderDate, perform: { value in
                cancelExistingReminder()
                if reminderEnabled {
                    createReminderNotification()
                }
            })
        }
    }
    
    func cancelExistingReminder() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
           var identifiers: [String] = []
           for notification:UNNotificationRequest in notificationRequests {
            if notification.identifier == notificationName {
                  identifiers.append(notification.identifier)
               }
           }
           UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
    
    func createReminderNotification() {
        
        let content = UNMutableNotificationContent()
        content.title = NotificationsName.creditCardNotificationTitle
        content.subtitle = NotificationsName.creditCardNotificationDescription + " - " + cardName
        content.sound = UNNotificationSound.default
        
        let nextReminderDate: Date = reminderDate
        let components = Calendar.current.dateComponents([.day, .hour, .minute], from: nextReminderDate)

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // Create the request
        let creditCardNotificationName = notificationName
        let request = UNNotificationRequest(identifier: creditCardNotificationName,
                    content: content, trigger: trigger)
        
        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
           if error != nil {
              // Handle any errors.
           }
        }
        
        // Update user defaults
        var reminderDict = settings.creditCardReminderDict
        
        reminderDict[creditCardNotificationName] = reminderDate
        settings.creditCardReminderDict = reminderDict
    }
}
