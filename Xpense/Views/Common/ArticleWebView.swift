//
//  ArticleWebView.swift
//  Xpense
//
//  Created by Teddy Santya on 22/11/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI
import Firebase

struct ArticleWebView: View {
    var body: some View {
        WebView(linkUrl: "https://www.nytimes.com/2020/08/03/smarter-living/coronavirus-budget-save-money.html")
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .onAppear {
                Analytics.logEvent(AnalyticsEventScreenView, parameters:[
                    AnalyticsParameterScreenName: "Article"
                ])
            }
            .navigationBarTitle(Text("Article"), displayMode: .inline)
    }
}

struct ArticleWebView_Previews: PreviewProvider {
    static var previews: some View {
        ArticleWebView()
    }
}
