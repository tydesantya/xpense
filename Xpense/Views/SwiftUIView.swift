//
//  SwiftUIView.swift
//  Xpense
//
//  Created by Teddy Santya on 12/5/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI

struct SwiftUIView: View {
    
    @State var textField = ""
    @State var secureField = ""
    
    var body: some View {
        VStack {
            Text("Hello, World!")
                .font(Font.title.bold().italic())
            TextField("TextField Placeholder", text: $textField)
            SecureField("SecureField Placeholder", text: $secureField)
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
