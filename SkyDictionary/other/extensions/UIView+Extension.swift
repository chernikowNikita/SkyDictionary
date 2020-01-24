//
//  UIView+Extension.swift
//  SkyDictionary
//
//  Created by Никита Черников on 22/01/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import UIKit

extension UIView {
    static var ClassName: String {
        return String(describing: self)
    }
    
    static var Nib: UINib {
        return UINib(nibName: ClassName, bundle: nil)
    }
    
    func fillSuperView() {
        guard let superView = self.superview else {
            return
        }
        self.leadingAnchor.constraint(equalTo: superView.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: superView.trailingAnchor).isActive = true
        self.topAnchor.constraint(equalTo: superView.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: superView.bottomAnchor).isActive = true
    }
}
