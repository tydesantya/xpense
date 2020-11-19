//
//  AppleSignInButton.swift
//  Xpense
//
//  Created by Teddy Santya on 7/11/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI
import AuthenticationServices
import CoreData

struct AppleSignInButton: UIViewRepresentable {
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        var buttonStyle: ASAuthorizationAppleIDButton.Style = .black
        if UITraitCollection.current.userInterfaceStyle == .dark {
            buttonStyle = .white
        }
        return ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: buttonStyle)
    }
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context:
                        Context) {
    }
}

// Used in login view model
class AppleSignInCoordinator: NSObject, ASAuthorizationControllerDelegate {
    
    let persistenceController = PersistenceController.shared
    
    // Shows Sign in with Apple UI
    func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    // Delegate methods
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            // Get user details
            
            let context = persistenceController.container.viewContext
            let fetchRequest = NSFetchRequest<Account>(entityName: "Account")
            
            do {
                let accounts = try context.fetch(fetchRequest)
                if accounts.count == 0 {
                    signUp(appleIDCredential: appleIDCredential)
                }
                else {
                    login(account: accounts.first!)
                }
            } catch let fetchError {
                print("Failed to fetch Account \(fetchError)")
            }
            
        // Save user details or fetch them
        // Sign in with Apple only gives full name and email once
        // Below is a sample code of how it can be done
        // Example: Make network request to backend
        // OR, perform any other operation as per your app's use case
        
        default:
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func signUp(appleIDCredential: ASAuthorizationAppleIDCredential) {
        let context = persistenceController.container.viewContext
        
        let userIdentifier = appleIDCredential.user
        let fullName = appleIDCredential.fullName
        let email = appleIDCredential.email ?? ""
        let name = (fullName?.givenName ?? "") + (" ") + (fullName?.familyName ?? "")
        
        let newAccount = Account(context: context)
        newAccount.identifier = userIdentifier
        newAccount.userName = name
        newAccount.userEmail = email
        
        do {
            try context.save()
            NotificationCenter.default.post(name: NSNotification.Name("AppleSignInSuccess"),
                                            object: nil,
                                            userInfo: [
                                                "userName": name,
                                                "userEmail": email,
                                                "identifier": userIdentifier
                                            ])
        } catch let createError {
            print("Failed to create Account \(createError)")
        }
    }
    
    func login(account: Account) {
        let userName = account.userName!
        let userEmail = account.userEmail!
        let userIdentifier = account.identifier!
        NotificationCenter.default.post(name: NSNotification.Name("AppleSignInSuccess"),
                                        object: nil,
                                        userInfo: [
                                            "userName": userName,
                                            "userEmail": userEmail,
                                            "identifier": userIdentifier
                                        ])
    }
}
