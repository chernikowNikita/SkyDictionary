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
            self.retryBtn.layer.cornerRadius = 5
        }
    }
    
    // MARK: - Create
    static func Create() -> ErrorView {
        return Nib.instantiate(withOwner: nil, options: nil).first as! ErrorView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
}
