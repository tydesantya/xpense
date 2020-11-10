//
//  FeedbackView.swift
//  Xpense
//
//  Created by Teddy Santya on 8/11/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI
import MessageUI
import Firebase

struct FeedbackView: View {
    @State var notes: String = ""
    @State var result: Result<MFMailComposeResult, Error>? = nil
    @State var isShowingMailView = false
    
    var body: some View {
        if MFMailComposeViewController.canSendMail() {
            ScrollView {
                VStack {
                    VStack {
                        ZStack {
                            Color.init(.secondarySystemBackground)
                                .cornerRadius(.normal)
                            ZStack(alignment: .topLeading) {
                                let labelText = notes.count > 0 ? notes : "Describe your feedback"
                                let textColor = notes.count > 0 ? Color.init(.label) : Color.init(.tertiaryLabel)
                                Text(labelText)
                                    .padding([.leading, .trailing], 5)
                                    .padding([.top, .bottom], 8)
                                    .foregroundColor(textColor)
                                TextEditor(text: self.$notes)
                            }
                            .padding(.small)
                        }
                        .padding()
                        .frame(minHeight: 200)
                        CTAButton(title: "Send Feedback") {
                            isShowingMailView.toggle()
                        }
                    }.padding()
                }
            }
            .onAppear {
                Analytics.logEvent(AnalyticsEventScreenView, parameters:[
                    "screenName": "Feedback"
                ])
            }
            .navigationTitle("Feedback")
            .sheet(isPresented: $isShowingMailView) {
                MailView(isShowing: self.$isShowingMailView, result: self.$result, body: $notes)
            }
        } else {
            VStack {
                Text("Mail is not set up on your device")
                CTAButton(title: "e-Mail Feedback to Developer") {
                    let _ = sendEmail()
                }
            }.padding()
            .navigationTitle("Feedback")
        }
        
    }
    
    func sendEmail() -> Bool {
        guard var feedbackUrl = URLComponents.init(string: "mailto:teddy@santya.net") else {
            return false
        }
        var queryItems: [URLQueryItem] = []
        queryItems.append(URLQueryItem.init(name: "SUBJECT", value: "Xpense Feedback"))
        feedbackUrl.queryItems = queryItems
        if let url = feedbackUrl.url {
            if UIApplication.shared.canOpenURL(url){
                UIApplication.shared.open(url)
                return true
            }
        }
        return true
    }
}

struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackView()
    }
}
