//
//  IntroScreenView.swift
//  Xpense
//
//  Created by Teddy Santya on 7/11/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI

struct IntroScreenView: View {
    
    @State var navigateToSignIn: Bool = false
    @Binding var showSheetView: SheetFlags?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Welcome to")
                .font(.hero)
                .fontWeight(.heavy)
            Text("Xpense")
                .font(.hero)
                .fontWeight(.heavy)
                .foregroundColor(.theme)
            Spacer()
            HStack {
                Spacer()
                Image(uiImage: UIImage(named: "logo")!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .cornerRadius(.medium)
                Spacer()
            }.padding()
            HStack {
                Spacer()
                Text("Track and manage your expenses from every payment method")
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .padding(.bottom)
            Spacer()
            HStack {
                Spacer()
                Image(systemSymbol: .shieldLefthalfFill)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .foregroundColor(.theme)
                Spacer()
            }.padding(.bottom)
            HStack {
                Spacer()
                Text("With your iCloud account you will be sync your transactions across devices by using the same account. We record your activity in this app but we don't record any of your transaction data, see full details on our privacy policy")
                    .font(.caption2)
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .multilineTextAlignment(.center)
                Spacer()
            }.padding(.bottom)
            CTAButton(title: "Continue") {
                navigateToSignIn = true
            }
            NavigationLink(
                destination: SignInView(showSheetView: $showSheetView),
                isActive: $navigateToSignIn,
                label: {
                    EmptyView()
                })
        }
        .padding(.extraLarge)
        .navigationBarHidden(true)
    }
}
