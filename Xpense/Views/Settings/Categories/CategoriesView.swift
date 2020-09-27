//
//  CategoriesView.swift
//  Xpense
//
//  Created by Teddy Santya on 26/9/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI

struct CategoriesView: View {
    
    @State var segmentIndex: Int = 0
    let segments = ["Expenses", "Income"]
    @State var dataSource: [Category]
    
    var body: some View {
        VStack {
            Picker(selection: self.$segmentIndex, label: Text("")) {
                ForEach(0..<self.segments.count) { index in
                    Text(String(self.segments[index]))
                }
            }
            .padding()
            .onChange(of: self.segmentIndex, perform: { value in
                self.segmentChanged(value)
            })
            .pickerStyle(SegmentedPickerStyle())
            CategoriesGrid(data: $dataSource)
        }
        .navigationTitle("Categories")
    }
    
    func segmentChanged(_ index: Int) {
        
    }
    
    func onAppear() {
        let category = Category(name: "Shopping", icon: UIImage(systemName: "bag.fill")!, color: .purple)
        self.dataSource = [category]
    }
}

struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesView(dataSource: [Category(name: "Shopping", icon: UIImage(systemName: "bag.fill")!, color: .purple)])
    }
}
