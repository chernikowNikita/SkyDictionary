//
//  SearchResult.swift
//  SkyDictionary
//
//  Created by Никита Черников on 14/01/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import Foundation

struct SearchResult: Codable {
    let id: Int
    let text: String
    let meanings: [Meaning]
}
