//
//  TopUpIconDisplayView.swift
//  Xpense
//
//  Created by Teddy Santya on 5/11/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI

struct TopUpIconDisplayView: View {
    var iconWidth: CGFloat
    var iconHeight: CGFloat
    var uiColor: UIColor
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(gradient: .init(colors: [Color(uiColor.lighter()!), Color(uiColor)]), startPoint: .top, endPoint: .bottom)
                )
                .frame(width: iconWidth, height: iconHeight)
            Image(systemSymbol: .plusSquareFill)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: iconWidth/2, height: iconWidth/2)
                .foregroundColor(.white)
            .foregroundColor(.white)
        }
    }
}

struct TopUpIconDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        TopUpIconDisplayView(iconWidth: 40, iconHeight: 40, uiColor: .systemRed)
    }
}
