//
//  UICollectionViewCell+Extension.swift
//  SkyDictionary
//
//  Created by Никита Черников on 22/01/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import UIKit

extension UICollectionViewCell {
    
    static func registerWithNib(in collectionView: UICollectionView) {
        return collectionView.register(Nib, forCellWithReuseIdentifier: ClassName)
    }
    
    static func deque(for collectionView: UICollectionView, indexPath: IndexPath) -> Self {
        return collectionView.dequeueReusableCell(withReuseIdentifier: ClassName, for: indexPath) as! Self
    }
    
}
