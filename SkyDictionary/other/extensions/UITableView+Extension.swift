//
//  UITableView+Extension.swift
//  SkyDictionary
//
//  Created by Никита Черников on 22/01/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import UIKit

extension UITableViewCell {
    
    static func registerWithNib(in tableView: UITableView) {
        tableView.register(Nib, forCellReuseIdentifier: ClassName)
    }
    
    static func deque(for tableView: UITableView, indexPath: IndexPath) -> Self {
        return tableView.dequeueReusableCell(withIdentifier: ClassName, for: indexPath) as! Self
    }
    
}
