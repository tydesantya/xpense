//
//  Design.swift
//  Covid-ID
//
//  Created by Teddy Santya on 1/5/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

fileprivate protocol FontStyle {
    var size: CGFloat { get }
    var weight: Font.Weight { get }
    var design: Font.Design { get }
}

enum Padding : CGFloat {
    case tiny = 4
    case small = 8
    case normal = 12
    case medium = 16
    case large = 24
}

extension CGFloat {
    public static var tiny: CGFloat = 4.0
    public static var small: CGFloat = 8.0
    public static var normal: CGFloat = 12.0
    public static var medium: CGFloat = 16.0
    public static var large: CGFloat = 24.0
}
extension Font {

    static var hero: Font {
        return getFontFromDesign(design: .hero)
    }
    
    static var huge: Font {
        return getFontFromDesign(design: .huge)
    }
    
    static var hugeTitle: Font {
        return getFontFromDesign(design: .hugeTitle)
    }
    
    static var header: Font {
        return getFontFromDesign(design: .header)
    }
    
    static var sectionTitle: Font {
        return getFontFromDesign(design: .sectionTitle)
    }
}

extension Font {
    
    enum FontDesign: FontStyle {
        case header
        case small
        case medium
        case large
        case huge
        case hero
        case hugeTitle
        case sectionTitle
        case buttonTitle
        
        var size: CGFloat {
            switch self {
            case .small:
                return 14.0
            case .medium, .buttonTitle:
                return 16.0
            case .large, .header, .sectionTitle:
                return 20.0
            case .huge:
                return 32.0
            case .hugeTitle:
                return 40.0
            case .hero:
                return 48.0
            }
        }
        
        var weight: Font.Weight {
            switch self {
            case .small, .medium, .large:
                return .regular
            case .header:
                return .medium
            case .huge, .hero, .hugeTitle, .sectionTitle, .buttonTitle:
                return .bold
            }
        }
        
        var design: Font.Design {
            return .default
        }
    }
    
    static func getFontFromDesign(design: FontDesign) -> Font {
        return Font.system(size: design.size, weight: design.weight, design: design.design)
    }
}

extension Color {
    public static var background: Color {
        return Color("background")
    }
    public static var shadow: Color {
        return Color("shadow")
    }
    public static var theme: Color {
        return Color.init(.systemGreen)
    }
}

extension UIColor {
    public static var background: UIColor {
        return UIColor(named:"background")!
    }
    public static var shadow: UIColor {
        return UIColor(named:"shadow")!
    }
    
    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }

    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }

    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
}


struct Shadow: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: Color.red.opacity(0.2), radius: 5.0 / 2, x: 0.0, y: 2.0)
    }
}

struct NeumorphismShadow: ViewModifier {
    var color: Color
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.5), radius: 8.0, x: 0.0, y: 10.0)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct Blur: UIViewRepresentable {
    var style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
