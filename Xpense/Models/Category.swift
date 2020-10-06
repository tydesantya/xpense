//
//  Category.swift
//  Xpense
//
//  Created by Teddy Santya on 27/9/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SFSafeSymbols
import UIKit

class Category {

    var name: String
    var icon: UIImage
    var color: UIColor
    
    init(name: String, icon: UIImage, color: UIColor) {
        self.name = name
        self.icon = icon
        self.color = color
    }
    
}
