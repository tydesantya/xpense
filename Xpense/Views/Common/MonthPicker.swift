//
//  MonthPicker.swift
//  Xpense
//
//  Created by Teddy Santya on 26/9/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI

extension Date {
    var year: Int { Calendar.current.component(.year, from: self) }
}
struct MonthPicker: View {
    @State var monthIndex: Int = 0
    @State var yearIndex: Int = 0
    var completion: (Int, Int) -> Void

    let monthSymbols = Calendar.current.monthSymbols
    let years = Array(Array(Date().year-11..<Date().year+1).reversed())

    var body: some View {
        GeometryReader{ geometry in
            VStack {
                Spacer()
                Text("Select Month and Year")
                    .foregroundColor(Color.init(.secondaryLabel))
                HStack(spacing: 0) {
                    Picker(selection: self.$monthIndex, label: Text("")) {
                        ForEach(0..<self.monthSymbols.count) { index in
                            Text(self.monthSymbols[index])
                        }
                    }
                    .onChange(of: self.monthIndex, perform: { value in
                        self.monthChanged(value)
                    })
                    .frame(maxWidth: geometry.size.width / 2).clipped()
                    Picker(selection: self.$yearIndex, label: Text("")) {
                        ForEach(0..<self.years.count) { index in
                            Text(String(self.years[index]))
                        }
                    }
                    .onChange(of: self.yearIndex, perform: { value in
                        self.yearChanged(value)
                    })
                    .frame(maxWidth: geometry.size.width / 2).clipped()
                }.background(
                    Blur(style: .systemUltraThinMaterial)
                        .foregroundColor(.white)
                )
                CTAButton(title: "Select") {
                    self.performCompletion()
                }
                .padding()
                Spacer()
            }
        }
    }
    func performCompletion() {
        self.completion(monthIndex+1, years[yearIndex])
    }
    
    func monthChanged(_ index: Int) {
        print("\(years[yearIndex]), \(index+1)")
        print("Month: \(monthSymbols[index])")
    }
    func yearChanged(_ index: Int) {
        print("\(years[index]), \(monthIndex+1)")
        print("Month: \(monthSymbols[monthIndex])")
    }
}

struct MonthPicker_Previews: PreviewProvider {
    static var previews: some View {
        MonthPicker(completion: {
            month, year in
            print(month, year)
        })
    }
}
