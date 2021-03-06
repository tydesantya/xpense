//
//  PrivacyPolicyView.swift
//  Xpense
//
//  Created by Teddy Santya on 8/11/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI
import WebKit
import Firebase

struct PrivacyPolicyView: View {
    var body: some View {
        WebView(fileName: "PrivacyPolicy")
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .onAppear {
                Analytics.logEvent(AnalyticsEventScreenView, parameters:[
                    AnalyticsParameterScreenName: "Privacy Policy"
                ])
            }.navigationBarTitle(Text("Privacy Policy"), displayMode: .inline)
        
    }
}

struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyPolicyView()
    }
}


struct WebView: UIViewRepresentable {
    
    var fileName: String?
    var linkUrl: String?
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let urlString = linkUrl {
            let url = URL(string: urlString)
            let request = URLRequest(url: url!)
            uiView.load(request)
        }
        else {
            let url = Bundle.main.url(forResource: fileName, withExtension: "html")
            let request = URLRequest(url: url!)
            uiView.load(request)
        }
    }
}
