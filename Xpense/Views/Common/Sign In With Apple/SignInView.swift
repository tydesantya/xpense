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
                .onTapGesture {
                    settings.userName = "Teddy Santya"
                    settings.userEmail = "Teddysantya@gmail.com"
                    Analytics.setDefaultEventParameters(
                    [
                        "userName": settings.userName,
                        "userEmail": settings.userEmail
                    ])
                    settings.hasSetupIntro = true
                    showSheetView = .wallet
                }
            Text("By signing in, you agree to our Terms of Use and Privacy Policy")
                .font(.caption2)
                .foregroundColor(Color(UIColor.secondaryLabel))
                .multilineTextAlignment(.center)
                .padding()
        }.navigationBarHidden(true)
        .padding()
    }
}
