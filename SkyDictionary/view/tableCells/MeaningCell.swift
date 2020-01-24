//
//  MeaningCell.swift
//  SkyDictionary
//
//  Created by Никита Черников on 15/01/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import UIKit

class MeaningCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var translationLabel: UILabel!
    
    override func prepareForReuse() {
        previewImageView.image = nil
        translationLabel.text = nil
        super.prepareForReuse()
    }
    
}
