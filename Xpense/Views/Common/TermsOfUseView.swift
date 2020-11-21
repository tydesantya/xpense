//
//  TermsOfUseView.swift
//  Xpense
//
//  Created by Teddy Santya on 8/11/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI
import Firebase

struct TermsOfUseView: View {
    var body: some View {
        WebView(fileName: "TermsOfUse")
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .onAppear {
                Analytics.logEvent(AnalyticsEventScreenView, parameters:[
                    "screenName": "Terms of use"
                ])
            }
            .navigationBarTitle(Text("Terms & Conditions"), displayMode: .inline)
    }
}

struct TermsOfUseView_Previews: PreviewProvider {
    static var previews: some View {
        TermsOfUseView()
    }
}
