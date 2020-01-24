//
//  Definition.swift
//  SkyDictionary
//
//  Created by Никита Черников on 17/01/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import Foundation

struct Definition: Codable {
    let text: String?
    private let privateSoundUrl: String?
    var soundUrl: String? {
        get {
            return self.privateSoundUrl?.httpsPrefixed
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case text
        case privateSoundUrl = "soundUrl"
    }
    
}
