//
//  ReminderDetailView.swift
//  Xpense
//
//  Created by Teddy Santya on 4/11/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI

struct ReminderDetailView: View {
    @State var dateSelection = Date()
    @State var reminderOn = false
    
    @ObservedObject var settings = UserSettings()
    var body: some View {
        VStack {
            Text("Reminder")
            VStack(spacing: .medium) {
                Toggle(isOn: $settings.creditCardReminderEnabled, label: {
                    Text("Enable Reminder")
                })
                DatePicker("Date & Time", selection: $settings.creditCardNotificationDate)
            }.padding()
            .frame(minHeight: 150)
            .onChange(of: settings.creditCardReminderEnabled, perform: { value in
                cancelExistingReminder()
                if value {
                    createReminderNotification()
                }
            })
        }
    }
    
    func cancelExistingReminder() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
           var identifiers: [String] = []
           for notification:UNNotificationRequest in notificationRequests {
            if notification.identifier == NotificationsName.creditCardNotification {
                  identifiers.append(notification.identifier)
               }
           }
           UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
    
    func createReminderNotification() {
        
        let content = UNMutableNotificationContent()
        content.title = NotificationsName.creditCardNotificationTitle
        content.subtitle = NotificationsName.creditCardNotificationDescription
        content.sound = UNNotificationSound.default
        
        let nextReminderDate: Date = settings.creditCardNotificationDate
        let components = Calendar.current.dateComponents([.day, .hour, .minute], from: nextReminderDate)

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // Create the request
        let creditCardNotificationName = NotificationsName.creditCardNotification
        let request = UNNotificationRequest(identifier: creditCardNotificationName,
                    content: content, trigger: trigger)
        
        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
           if error != nil {
              // Handle any errors.
           }
        }
    }
}

struct ReminderDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ReminderDetailView()
    }
}
