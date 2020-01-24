//
//  Meaning.swift
//  SkyDictionary
//
//  Created by Никита Черников on 14/01/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import Foundation
import RxDataSources

struct Meaning: Codable {
    
    let id: Int
    let translation: Translation?
    private let privatePreviewUrl: String?
    var previewUrl: String? {
        get {
            return self.privatePreviewUrl?.httpsPrefixed
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case translation
        case privatePreviewUrl = "previewUrl"
    }
}
