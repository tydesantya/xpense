//
//  ProgressBar.swift
//  Xpense
//
//  Created by Teddy Santya on 26/9/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI

struct ProgressBar: View {
    @Binding var progress: Float
    var color: UIColor
    var lineWidth: CGFloat = 15.0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: lineWidth)
                .opacity(0.3)
                .foregroundColor(Color.init(color))
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.init(color))
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear)
        }
    }
}
