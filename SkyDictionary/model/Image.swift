//
//  Image.swift
//  SkyDictionary
//
//  Created by Никита Черников on 17/01/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import Foundation

struct Image: Codable {
    private let privateUrl: String
    var url: String {
        get {
            return privateUrl.httpsPrefixed
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case privateUrl = "url"
    }
}
