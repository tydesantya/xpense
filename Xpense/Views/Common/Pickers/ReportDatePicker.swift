//
//  ReportDatePicker.swift
//  Xpense
//
//  Created by Teddy Santya on 26/9/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI

extension Date {
    var year: Int { Calendar.iso8601.component(.year, from: self) }
}

enum ReportDatePickerType: String, CaseIterable {
    case day = "Day"
    case month = "Month"
    case year = "Year"
}

struct ReportDatePicker: View {
    @State var monthIndex: Int = 0
    @State var yearIndex: Int = 0
    @Binding var dateSelection: Date

    var type: ReportDatePickerType
    let monthSymbols = Calendar.current.monthSymbols
    let years = Array(Array(Date().year-11..<Date().year+1).reversed())

    var body: some View {
        GeometryReader {
            geometry in
            ZStack {
                VStack {
                    Text(getTitle())
                        .font(.sectionTitle)
                        .padding(.top)
                    if type == .day {
                        DatePicker("", selection: $dateSelection, displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding()
                            .scaleEffect(1.1)
                    }
                    else {
                        HStack(spacing: 0) {
                            Spacer()
                            if type == .month {
                                Picker(selection: self.$monthIndex, label: Text("")) {
                                    ForEach(0..<self.monthSymbols.count) { index in
                                        Text(self.monthSymbols[index])
                                    }
                                }
                                .onChange(of: self.monthIndex, perform: { value in
                                    self.monthChanged(value)
                                })
                                .frame(maxWidth: geometry.size.width / 2)
                                .clipped()
                                .pickerStyle(WheelPickerStyle())
                                .labelsHidden()
                            }
                            Picker(selection: self.$yearIndex, label: Text("")) {
                                ForEach(0..<self.years.count) { index in
                                    Text(String(self.years[index]))
                                }
                            }
                            .onChange(of: self.yearIndex, perform: { value in
                                self.yearChanged(value)
                            })
                            .frame(maxWidth: getYearPickerWidth(geometryWidth: geometry.size.width))
                            .clipped()
                            .pickerStyle(WheelPickerStyle())
                            .labelsHidden()
                            Spacer()
                        }
                    }
                }.onAppear {
                    if let monthInt = Calendar.iso8601.dateComponents([.month], from: dateSelection).month {
                        self.monthIndex = monthInt - 1
                    }
                    if let yearInt = Calendar.iso8601.dateComponents([.year], from: dateSelection).year {
                        self.yearIndex = years.firstIndex(of: yearInt) ?? 0
                    }
                }.frame(maxWidth: geometry.size.width - 50, alignment: .center)
            }.frame(width: geometry.size.width)
        }.frame(maxHeight: getMaxHeight(), alignment: .center)
    }
    
    func getMaxHeight() -> CGFloat {
        return type == .day ? 400 : 260
    }
    
    func getTitle() -> String {
        switch type {
        case .day:
            return "Select Date"
        case .month:
            return "Select Month and Year"
        default:
            return "Select Year"
        }
    }
    
    func getYearPickerWidth(geometryWidth: CGFloat) -> CGFloat {
        return type == .month ? geometryWidth / 2 : geometryWidth
    }
    
    func monthChanged(_ index: Int) {
        updateDate()
    }
    func yearChanged(_ index: Int) {
        updateDate()
    }
    
    func updateDate() {
        let month = monthSymbols[monthIndex]
        let year = years[yearIndex]
        let monthYear = "\(month) \(year)"
        if let date = dateFormatter.date(from: monthYear) {
            dateSelection = date
        }
    }
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
    
}

struct ReportDatePicker_Previews: PreviewProvider {
    static var previews: some View {
        ReportDatePicker(dateSelection: .constant(Date()), type: .day)
    }
}
