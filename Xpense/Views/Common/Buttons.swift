//
//  ButtonStyle.swift
//  Xpense
//
//  Created by Teddy Santya on 26/9/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI

struct CTAButton: View {
    
    var title: String = "Button"
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            self.action()
        }) {
            HStack {
                Text(title)
                    .foregroundColor(.white)
                    .font(.header)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .background(
                Color.theme
            )
            .cornerRadius(8.0)
        }
    }
}

struct PrimaryButton: View {
    
    var title: String = "Button"
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            self.action()
        }) {
            HStack {
                Text(title)
                    .foregroundColor(.theme)
                    .padding(.horizontal, .small)
                Spacer()
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding(.normal)
            .background(
                Color.init(.secondarySystemBackground)
            )
            .cornerRadius(.small)
        }
    }
}

struct PillButton: View {
    
    var body: some View {
        Button(action: {
            
        }, label: {
            Text("Add Transaction")
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.vertical, .small)
        })
        .background(Capsule()
                        .fill(Color.theme)
        )
    }
}

struct Buttons_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CTAButton {
                
            }
            PrimaryButton {
                
            }
            PillButton()
        }
    }
}
