//
//  TransactionCellView.swift
//  Xpense
//
//  Created by Teddy Santya on 10/10/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI

struct TransactionCellView: View {
    
    var category: Category
    
    var navigationDestination: ((AnyView?) -> Void)? = nil
    
    var body: some View {
        HStack(alignment: .bottom) {
            HStack(spacing: .medium) {
                // todo
//                Image(uiImage: category.icon)
//                    .renderingMode(.template)
//                    .foregroundColor(.white)
//                    .frame(width: 40, height: 40)
//                    .background(
//                        Circle().fill(Color.init(category.color))
//                            .frame(width: 40, height: 40)
//                    )
                VStack(alignment: .leading) {
                    Text("Shopping")
                        .bold()
                    Text("-Rp. 100,000")
                        .font(.title)
                        .bold()
                        .foregroundColor(.init(.systemRed))
                }
            }
            Spacer()
            HStack {
                Text("Thursday")
                Image(systemSymbol: .chevronRight)
            }
            .foregroundColor(.init(.secondaryLabel))
            .font(.caption)
        }
        .padding()
        .background(
            Color.init(.secondarySystemBackground)
            .cornerRadius(16)
        )
        .onTapGesture {
            if let navigation = navigationDestination {
                navigation(generateDestinationView())
            }
        }
    }
    
    func generateDestinationView() -> AnyView {
        return AnyView(SwiftUIView())
    }
}

//struct TransactionCellView_Previews: PreviewProvider {
//    static var previews: some View {
//        TransactionCellView(category: Category(name: "Shopping", icon: UIImage(systemName: "bag.fill")!, color: .purple))
//    }
//}
