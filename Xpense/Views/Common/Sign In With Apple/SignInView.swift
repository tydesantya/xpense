//
//  SignInView.swift
//  Xpense
//
//  Created by Teddy Santya on 7/11/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI
import Firebase

struct SignInView: View {
    var appleSignInCoordinator = AppleSignInCoordinator()
    @Binding var showSheetView: SheetFlags?
    @ObservedObject var settings = UserSettings()
    @FetchRequest(sortDescriptors: [])
    private var paymentMethods: FetchedResults<PaymentMethod>
    
    let persistenceController = PersistenceController.shared
    
    let pub = NotificationCenter.default
        .publisher(for: NSNotification.Name("AppleSignInSuccess"))
    
    var body: some View {
        VStack {
            HStack {
                Text("Sign In")
                    .font(.hero)
                    .fontWeight(.heavy)
                Spacer()
            }
            .padding()
            Spacer()
            Image(systemSymbol: .icloudFill)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .padding(.vertical, .large)
            Text("We use iCloud to store all your transactions so you can use this across different devices with the same Apple ID")
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
            HStack {
                Image(uiImage: UIImage(named: "logo")!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .cornerRadius(.medium)
                    .padding()
                Text("-")
                    .font(.largeTitle)
                Image(systemSymbol: .arrow2Circlepath)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .padding()
            }
            Text("Sign in to make sure you're signed in to your iCloud account to sync your data")
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
            AppleSignInButton()
                .frame(height: 60)
                .onTapGesture {settings.hasSetupIntro = true
                    #if DEBUG
                    
                    if paymentMethods.count == 0 {
                        showSheetView = .wallet
                    }
                    else {
                        showSheetView = nil
                    }
                    #else
                    
                    appleSignInCoordinator.handleAuthorizationAppleIDButtonPress()
                    #endif
                }
            Text("By signing in, you agree to our Terms of Use and Privacy Policy")
                .font(.caption2)
                .foregroundColor(Color(UIColor.secondaryLabel))
                .multilineTextAlignment(.center)
                .padding()
        }.navigationBarHidden(true)
        .padding()
        .onReceive(pub) { (output) in
            self.onSignInSuccess(output: output)
        }
    }
    
    func onSignInSuccess(output: NotificationCenter.Publisher.Output) {
        persistenceController.validateCategoriesSeed()
        if let userInfo = output.userInfo, let userName = userInfo["userName"], let userEmail = userInfo["userEmail"], let userIdentifier = userInfo["identifier"] {
            settings.userName = userName as! String
            settings.userEmail = userEmail as! String
            settings.userIdentifier = userIdentifier as! String
            Analytics.setDefaultEventParameters(
                [
                    "userName": userName as! String,
                    "userEmail": userEmail as! String
                ])
            settings.hasSetupIntro = true
            if paymentMethods.count == 0 {
                showSheetView = .wallet
            }
            else {
                showSheetView = nil
            }
            print("signed in: \(userName) \(userEmail) \(userIdentifier)")
        }
    }
}
