//
//  UserSettings.swift
//  Xpense
//
//  Created by Teddy Santya on 4/11/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import Foundation
import Combine

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

final class UserSettings: ObservableObject {

    let objectWillChange = PassthroughSubject<Void, Never>()

    @UserDefault("creditCardReminderEnabled", defaultValue: true)
    var creditCardReminderEnabled: Bool {
        willSet {
            objectWillChange.send()
        }
    }
    
    @UserDefault(UserDefaultsKey.creditCardNotificationDate, defaultValue: Date())
    var creditCardNotificationDate: Date {
        willSet {
            objectWillChange.send()
        }
    }
}