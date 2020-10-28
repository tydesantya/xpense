//
//  CategoryIconDisplayView.swift
//  Xpense
//
//  Created by Teddy Santya on 29/10/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI
import SFSafeSymbols

struct CategoryIconDisplayView: View {
    var category: CategoryModel
    var iconWidth: CGFloat
    var iconHeight: CGFloat
    var body: some View {
        let customTextIcon = category.text
        let symbolSelection:SFSymbol = SFSymbol(rawValue: category.symbolName ?? "") ?? .archiveboxFill
        ZStack {
            Circle()
                .fill(
                    LinearGradient(gradient: .init(colors: [Color(UIColor.color(data: category.lighterColor!)!), Color(UIColor.color(data: category.color!)!)]), startPoint: .top, endPoint: .bottom)
                )
                .frame(width: iconWidth, height: iconHeight)
            if let text = customTextIcon {
                Text(text)
                    .font(.system(size: iconWidth/2, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            else {
                Image(systemSymbol: symbolSelection)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconWidth/2, height: iconWidth/2)
                    .foregroundColor(.white)
                .foregroundColor(.white)
            }
        }
    }
}
