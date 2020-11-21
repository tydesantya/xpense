//
//  SetupSecurityView.swift
//  Xpense
//
//  Created by Teddy Santya on 8/11/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI
import LocalAuthentication
import SPAlert
import Firebase

struct SetupSecurityView: View {
    
    @ObservedObject var settings = UserSettings()
    
    var body: some View {
        VStack {
            HStack {
                Image(systemSymbol: .faceid)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .padding()
                Text("/")
                    .font(.largeTitle)
                Image(systemName: "touchid")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .padding()
            }
            .padding()
            .padding(.top, .extraLarge)
            Text("Setup Security To Unlock Your App")
                .bold()
            Toggle(isOn: $settings.securityEnabled, label: {
                Text("Security Enabled")
            })
            .onChange(of: settings.securityEnabled, perform: { value in
                if value {
                    authenticate()
                }
            })
            .padding()
            .background(RoundedRectangle(cornerRadius: .medium).fill(Color(UIColor.secondarySystemBackground)))
            .padding()
            Spacer()
        }
        .onAppear {
            Analytics.logEvent(AnalyticsEventScreenView, parameters:[
                AnalyticsParameterScreenName: "Security"
            ])
        }
        .padding()
        .navigationTitle("Security")
    }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?

        // check whether biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // it's possible, so go ahead and use it
            let reason = "Lock this app so only you can access"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                // authentication has now completed
                DispatchQueue.main.async {
                    if success {
                        SPAlert.present(title: "Success", preset: .done)
                    } else {
                        settings.securityEnabled = false
                    }
                }
            }
        } else {
            settings.securityEnabled = false
        }
    }
}

struct SetupSecurityView_Previews: PreviewProvider {
    static var previews: some View {
        SetupSecurityView()
    }
}
