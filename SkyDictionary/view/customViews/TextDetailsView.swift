//
//  TextDetailsView.swift
//  SkyDictionary
//
//  Created by Никита Черников on 18/01/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import Foundation
import UIKit

class TextDetailsView: UIView {
    // MARK: - IBoutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var detailsStackView: UIStackView!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var detailsSoundBtn: LoadableButton!
    
    // MARK: - Create
    static func Create() -> TextDetailsView {
        return Nib.instantiate(withOwner: nil, options: nil).first as! TextDetailsView
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
