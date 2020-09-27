//
//  CategoriesGrid.swift
//  Xpense
//
//  Created by Teddy Santya on 26/9/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI

struct CategoriesGrid: View {
    
    @Binding var data: [Category]
    
    var flexibleLayout = [GridItem(.flexible()), GridItem(.flexible())]
    var body: some View {
        ScrollView {
            LazyVGrid(columns: flexibleLayout, spacing: .small) {
                ForEach(0..<50) { index in
                    Button(action: {
                        
                    }){
                        CategoryItem(category: data[0])
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct CategoryItem: View {
    
    var category: Category
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
            }
            Image(uiImage: category.icon)
                .renderingMode(.template)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(
                    Circle().fill(Color.init(category.color))
                        .frame(width: 40, height: 40)
                )
            Text(category.name)
                .foregroundColor(.white)
        }
        .padding()
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
        .background(
            LinearGradient(gradient: Gradient(colors: [.init(category.color.lighter(by: 10.0)!), .init(category.color)]), startPoint: .center, endPoint: .trailing)
        )
        .cornerRadius(.normal)
    }
}

struct CategoriesGrid_Previews: PreviewProvider {
    
    
    static var previews: some View {
        CategoriesGrid(data: Binding(get: {
            return [Category(name: "Shopping", icon: UIImage(systemName: "bag.fill")!, color: .purple)]
        }, set: { (_) in
            
        }))
    }
}
