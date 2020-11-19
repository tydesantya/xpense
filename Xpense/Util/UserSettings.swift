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
    
    @UserDefault("creditCardReminderDict", defaultValue: [:])
    var creditCardReminderDict: [String:Date] {
        willSet {
            objectWillChange.send()
        }
    }
    
    @UserDefault("hasSetupIntro", defaultValue: false)
    var hasSetupIntro: Bool {
        willSet {
            objectWillChange.send()
        }
    }
    
    
    @UserDefault("securityEnabled", defaultValue: false)
    var securityEnabled: Bool {
        willSet {
            objectWillChange.send()
        }
    }
    
    @UserDefault("userName", defaultValue: "")
    var userName: String {
        willSet {
            objectWillChange.send()
        }
    }
    
    @UserDefault("userEmail", defaultValue: "")
    var userEmail: String {
        willSet {
            objectWillChange.send()
        }
    }
    
    @UserDefault("userIdentifier", defaultValue: "")
    var userIdentifier: String {
        willSet {
            objectWillChange.send()
        }
    }
}
