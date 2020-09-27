//
//  ContentView.swift
//  Xpense
//
//  Created by Teddy Santya on 8/5/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State private var selection: Int = 1
    @State var navigationBarTitle: String = "Xpense"
    var body: some View {
        NavigationView {
            TabView(selection: $selection) {
                XpenseView().tabItem {
                    Image(systemName: "x.circle")
                    Text("Xpense")
                }.tag(1)
                SettingsView().tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }.tag(2)
            }
            .accentColor(.theme)
            .navigationBarTitle(self.navigationBarTitle)
            .onChange(of: selection, perform: { value in
                switch value {
                case 1:
                    self.navigationBarTitle = "Xpense"
                case 2:
                    self.navigationBarTitle = "Settings"
                default:
                    break
                }
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
