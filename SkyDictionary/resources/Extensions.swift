//
//  Extensions.swift
//  SkyDictionary
//
//  Created by Никита Черников on 18/01/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import Foundation
import UIKit

extension NSObject {
    static var ClassName: String {
        return String(describing: self)
    }
}

extension String {
    var httpsPrefixed: String {
        get {
            return "https:\(self)"
        }
    }
}

extension UIView {
    static var Nib: UINib {
        return UINib(nibName: ClassName, bundle: nil)
    }
    
    func fitSuperView() {
        guard let superView = self.superview else {
            return
        }
        self.centerXAnchor.constraint(equalTo: superView.centerXAnchor).isActive = true
        self.centerYAnchor.constraint(equalTo: superView.centerYAnchor).isActive = true
//        self.leadingAnchor.constraint(equalTo: superView.leadingAnchor).isActive = true
//        self.trailingAnchor.constraint(equalTo: superView.trailingAnchor).isActive = true
//        self.topAnchor.constraint(equalTo: superView.topAnchor).isActive = true
//        self.bottomAnchor.constraint(equalTo: superView.bottomAnchor).isActive = true
    }
}

extension UITableViewCell {
    
    static func register(in tableView: UITableView) {
        return tableView.register(self, forCellReuseIdentifier: ClassName)
    }
    
    static func deque(for tableView: UITableView, indexPath: IndexPath) -> Self {
        return tableView.dequeueReusableCell(withIdentifier: ClassName, for: indexPath) as! Self
    }
    
}

extension UICollectionViewCell {
    
    static func register(in collectionView: UICollectionView) {
        return collectionView.register(Nib, forCellWithReuseIdentifier: ClassName)
    }
    
    static func deque(for collectionView: UICollectionView, indexPath: IndexPath) -> Self {
        return collectionView.dequeueReusableCell(withReuseIdentifier: ClassName, for: indexPath) as! Self
    }
    
}