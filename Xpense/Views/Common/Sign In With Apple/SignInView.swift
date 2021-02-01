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
    @State var refreshFlag = UUID()
    @State var finishSignIn = false
    @State var finishSync = false
    @State var showLoading = false
    @State var timer: Timer.TimerPublisher = Timer.publish (every: 5, on: .main, in: .common)
    
    let persistenceController = PersistenceController.shared
    
    let pub = NotificationCenter.default
        .publisher(for: NSNotification.Name("AppleSignInSuccess"))
    let updated = NotificationCenter.default.publisher(for: NSNotification.Name("RemoteObjectReceived"))
    
    var body: some View {
        VStack {
            if showLoading {
                ProgressView()
            }
            else {
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
                    .id(refreshFlag)
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
                        #if DEBUG
                        settings.hasSetupIntro = true
                        persistenceController.validateCategoriesSeed()
                        finishSignIn = true
                        verifyCompletion(showLoading: true)
                        
                        #else
                        
                        appleSignInCoordinator.handleAuthorizationAppleIDButtonPress()
                        #endif
                    }
                Text("By signing in, you agree to our Terms of Use and Privacy Policy")
                    .font(.caption2)
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }.navigationBarHidden(true)
        .padding()
        .onReceive(pub) { (output) in
            self.onSignInSuccess(output: output)
        }
        .onReceive(updated, perform: { _ in
            self.cancelTimer()
            self.instantiateTimer()
            let _ = self.timer.connect()
        })
        .onReceive(timer) { _ in
            onNoLongerReceiveObjectAfterTimer()
            self.cancelTimer()
        }
    }
    
    
    func instantiateTimer() {
        self.timer = Timer.publish (every: 5, on: .main, in: .common)
        return
    }
    
    func cancelTimer() {
        self.timer.connect().cancel()
        return
    }
    
    func onNoLongerReceiveObjectAfterTimer() {
        refreshFlag = UUID()
        finishSync = true
        verifyCompletion()
    }
    
    func onSignInSuccess(output: NotificationCenter.Publisher.Output) {
        if let userInfo = output.userInfo, let userName = userInfo["userName"], let userEmail = userInfo["userEmail"], let userIdentifier = userInfo["identifier"] {
            settings.userName = userName as! String
            settings.userEmail = userEmail as! String
            settings.userIdentifier = userIdentifier as! String
            Analytics.setDefaultEventParameters(
                [
                    "userName": userName as! String,
                    "userEmail": userEmail as! String
                ])
            Analytics.logEvent(AnalyticsEventSignUp, parameters:[
                "userName": userName as! String,
                "userEmail": userEmail as! String
            ])
            finishSignIn = true
            verifyCompletion(showLoading: true)
        }
    }
    
    func verifyCompletion(showLoading:Bool = false) {
        if showLoading {
            self.showLoading = true
        }
        if finishSignIn && finishSync {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                persistenceController.validateCategoriesSeed()
                settings.hasSetupIntro = true
                if paymentMethods.count == 0 {
                    showSheetView = .wallet
                }
                else {
                    showSheetView = nil
                }
            }
        }
    }
}
