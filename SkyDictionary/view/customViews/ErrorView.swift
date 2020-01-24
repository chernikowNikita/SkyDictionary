//
//  ErrorView.swift
//  SkyDictionary
//
//  Created by Никита Черников on 19/01/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import Foundation
import UIKit

class ErrorView: UIView {
    // MARK: - IBoutlets
    @IBOutlet weak var retryBtn: UIButton! {
        didSet {
            if let button = self.retryBtn {
                button.layer.cornerRadius = 5
            }
        }
    }
    
    // MARK: - Create
    static func Create(autolayout: Bool) -> ErrorView {
        let view = Nib.instantiate(withOwner: nil, options: nil).first as! ErrorView
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 120)
        if autolayout {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        return view
    }
    
}
