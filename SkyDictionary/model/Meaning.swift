//
//  Meaning.swift
//  SkyDictionary
//
//  Created by Никита Черников on 17/01/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import Foundation

struct Meaning: Codable {
    let id: String
    let text: String
    let wordId: Int
    let difficultyLevel: Int?
    private let privateSoundUrl: String?
    var soundUrl: String? {
        get {
            return self.privateSoundUrl?.httpsPrefixed
        }
    }
    let transcription: String?
    let translation: Translation?
    let images: [Image]
    let definition: Definition?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case text
        case wordId
        case difficultyLevel
        case privateSoundUrl = "soundUrl"
        case transcription
        case translation
        case images
        case definition
    }
}
