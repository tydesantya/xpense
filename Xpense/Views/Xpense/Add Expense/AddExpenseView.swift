//
//  AddExpenseView.swift
//  Xpense
//
//  Created by Teddy Santya on 27/9/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI

struct AddExpenseView: View {
    @Binding var showSheetView: Bool
    var body: some View {
        NavigationView {
            Text("Sheet View content")
                .navigationBarTitle(Text("Sheet View"), displayMode: .inline)
                .navigationBarItems(trailing: Button(action: {
                    print("Dismissing sheet view...")
                    self.showSheetView = false
                }) {
                    Text("Done").bold()
                })
        }
    }
}

struct AddExpenseView_Previews: PreviewProvider {
    
    static var previews: some View {
        AddExpenseView(showSheetView: Binding<Bool>(get: {
            return true
        }, set: { (flag) in
        
        }))
    }
}
