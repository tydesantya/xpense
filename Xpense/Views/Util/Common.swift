//
//  Common.swift
//  Xpense
//
//  Created by Teddy Santya on 22/10/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI

struct TrayIndicator: View {
    @State var text: String = ""
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Spacer()
                RoundedRectangle(cornerRadius: .tiny / 2)
                    .fill(Color.init(.systemGray))
                    .frame(width: 40, height: .tiny)
                    .padding(.top, .small)
                Spacer()
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
 
    @State private var isEditing = false
 
    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .padding(.small)
                .background(Color(.tertiarySystemGroupedBackground))
                .cornerRadius(8)
                .padding(.horizontal, 10)
                .onTapGesture {
                    self.isEditing = true
                }
                .introspectTextField(customize: UITextField.introspect())
            if isEditing {
                Button(action: {
                    self.isEditing = false
                    self.text = ""
 
                }) {
                    Text("Cancel")
                }
                .padding(.trailing, .small)
                .transition(.move(edge: .trailing))
                .animation(.default)
            }
        }
        .padding(.horizontal, .small)
    }
}
struct Common_Previews: PreviewProvider {
    static var previews: some View {
        TrayIndicator()
    }
}
