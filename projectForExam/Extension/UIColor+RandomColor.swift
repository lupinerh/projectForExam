//
//  UIColor+RandomColor.swift
//  project
//
//  Created by Stanislav Korolev on 24.02.18.
//  Copyright © 2018 Stanislav Korolev. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    static func randomColor() -> UIColor{
        let red = CGFloat(drand48())
        let green = CGFloat(drand48())
        let blue = CGFloat(drand48())
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    static func randomLightColor() -> UIColor {
        let red = CGFloat(arc4random_uniform(50) + 200)
        let green = CGFloat(arc4random_uniform(50) + 200)
        let blue = CGFloat(arc4random_uniform(50) + 200)
        
        print(red)
        print(green)
        print(blue)
        
        return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
    }
    
}
