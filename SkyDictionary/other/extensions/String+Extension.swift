//
//  String+Extension.swift
//  SkyDictionary
//
//  Created by Никита Черников on 22/01/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import Foundation

extension String {
    var httpsPrefixed: String {
        get {
            return "https:\(self)"
        }
    }
}
