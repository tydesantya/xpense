//
//  SettingsView.swift
//  Xpense
//
//  Created by Teddy Santya on 26/9/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @State var navigate: Bool = false
    @State var destinationView: AnyView?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Transaction")
                    .font(.getFontFromDesign(design: .sectionTitle))
                VStack {
                    LazyVStack {
                        MenuView(iconName: "dollarsign.circle.fill", text: "Budget", action: self.menuTapped(title:))
                        Divider()
                            .padding(.bottom, .tiny)
                        MenuView(iconName: "rectangle.stack.fill", text: "Categories", action: self.menuTapped(title:))
                        Divider()
                            .padding(.bottom, .tiny)
                        MenuView(iconName: "dollarsign.circle.fill", text: "Theme", action: self.menuTapped(title:))
                    }
                }
                .padding()
                .background(Color.init(.secondarySystemBackground))
                .cornerRadius(.medium)
                NavigationLink(
                    destination: destinationView,
                    isActive: self.$navigate,
                    label: {
                        EmptyView()
                    })
            }
            .padding()
        }
        .navigationBarTitle("Settings")
    }
    
    func menuTapped(title: String) {
        switch title {
        case "Budget":
            destinationView = AnyView(SwiftUIView())
        case "Categories":
            print("temp todo")
            destinationView = AnyView(
                CategoriesView()
                    .environment(\.managedObjectContext, self.viewContext)
            )
        default:
            destinationView = nil
        }
        self.navigate = true
    }
}

struct MenuView: View {
    
    var iconName: String
    var text: String
    var action: (String) -> Void
    
    var body: some View {
        Button(action: {
            self.action(text)
        }) {
            HStack {
                Image(systemName: iconName)
                Text(text)
                    .font(.getFontFromDesign(design: .buttonTitle))
                    .foregroundColor(Color.init(.label))
                Spacer()
                Image(systemName: "chevron.right")
            }
        }
        
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
