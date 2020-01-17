//
//  UITableViewCell+Extensions.swift
//  SkyDictionary
//
//  Created by Никита Черников on 16/01/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import UIKit

extension UITableViewCell {
    
    static func getReuseId() -> String {
        return String(describing: self)
    }
    
    static func register(in tableView: UITableView) {
        return tableView.register(self, forCellReuseIdentifier: getReuseId())
    }
    
    static func deque(for tableView: UITableView, indexPath: IndexPath) -> Self {
        return tableView.dequeueReusableCell(withIdentifier: getReuseId(), for: indexPath) as! Self
    }
    
}
