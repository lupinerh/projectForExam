//
//  File.swift
//  Demo
//
//  Created by Stanislav Korolev on 05.01.18.
//  Copyright © 2018 Stanislav Korolev. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func addConstraints(withFormat format: String, views: UIView...){
        
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated(){
            let key = "v\(index)"
            viewsDictionary[key] = view
            //отключаем autoresize маску и сами добавляем констреинты
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
    
    
    
    // вроде не используется
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
            
    }

}
