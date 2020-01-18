//
//  Extensions.swift
//  SkyDictionary
//
//  Created by Никита Черников on 18/01/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import Foundation

extension NSObject {
    static var ClassName: String {
        return String(describing: self)
    }
}
