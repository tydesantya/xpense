//
//  BudgetDatePickerView.swift
//  Xpense
//
//  Created by Teddy Santya on 2/11/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI

struct BudgetDatePickerView: View {
    
    @FetchRequest(
        entity: PeriodicBudget.entity(),
        sortDescriptors: [
            NSSortDescriptor(key: "startDate", ascending: true)
        ]
    ) var budgets: FetchedResults<PeriodicBudget>
    
    @State var monthIndex: Int = 0
    @State var yearIndex: Int = 0
    @Binding var dateSelection: Date
    @Binding var endingDateSelection: Date

    var type: BudgetPeriod
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
                    if type == .daily {
                        DatePicker("", selection: $dateSelection, in: minDate...maxDate, displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding()
                            .scaleEffect(1.1)
                            .onChange(of: dateSelection, perform: { value in
                                endingDateSelection = dateSelection.endOfDay
                            })
                    }
                    else {
                        HStack(spacing: 0) {
                            Spacer()
                            if type == .weekly {
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
        return type == .daily ? 400 : 260
    }
    
    func getTitle() -> String {
        switch type {
        case .daily:
            return "Select Date"
        case .weekly:
            return "Select Start & End Date"
        default:
            return "Select Year"
        }
    }
    
    func getYearPickerWidth(geometryWidth: CGFloat) -> CGFloat {
        return geometryWidth
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
    
    func mapWeeklyDates() -> [[Date:Date]] {
        var weeklyDicts: [[Date:Date]] = []
        for periodBudget in budgets {
            if let startDate = periodBudget.startDate, let endDate = periodBudget.endDate {
                weeklyDicts.append([startDate:endDate])
            }
        }
        return weeklyDicts
    }
    
    var minDate: Date {
        budgets.first!.startDate!
    }
    
    var maxDate: Date {
        budgets.last!.startDate!
    }
}

struct BudgetDatePickerView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetDatePickerView(dateSelection: .constant(Date()), endingDateSelection: .constant(Date()), type: .daily)
    }
}
