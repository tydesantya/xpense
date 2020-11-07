//
//  AppleSignInButton.swift
//  Xpense
//
//  Created by Teddy Santya on 7/11/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI
import AuthenticationServices


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
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email ?? ""
            let name = (fullName?.givenName ?? "") + (" ") + (fullName?.familyName ?? "")
            
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
}
