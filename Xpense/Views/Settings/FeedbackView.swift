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
            Text("Can't send emails from this device")
        }
        
    }
}

struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackView()
    }
}
