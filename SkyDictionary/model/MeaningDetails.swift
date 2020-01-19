//
//  MeaningDetails.swift
//  SkyDictionary
//
//  Created by Никита Черников on 17/01/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import Foundation

struct MeaningDetails: Codable {
    let id: String
    let text: String
    let wordId: Int
    let difficultyLevel: Int?
    private let partOfSpeechCode: String
    var partOfSpeech: PartOfSpeech? {
        get {
            return PartOfSpeech(rawValue: partOfSpeechCode)
        }
    }
    let soundUrl: String?
    let transcription: String?
    let translation: Translation?
    let images: [Image]
    let definition: Definition?
    
    static let empty = MeaningDetails(id: "nil", text: "nil", wordId: 0, difficultyLevel: 0, partOfSpeechCode: "nil", soundUrl: nil, transcription: nil, translation: nil, images: [], definition: nil)
    
    private enum CodingKeys: String, CodingKey {
        case id
        case text
        case wordId
        case difficultyLevel
        case partOfSpeechCode
        case soundUrl
        case transcription
        case translation
        case images
        case definition
    }
}
