//
//  Common.swift
//  Xpense
//
//  Created by Teddy Santya on 22/10/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI

struct TrayIndicator: View {
    var body: some View {
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

struct Common_Previews: PreviewProvider {
    static var previews: some View {
        TrayIndicator()
    }
}
