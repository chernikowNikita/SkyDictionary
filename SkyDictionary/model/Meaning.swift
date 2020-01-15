//
//  Meaning.swift
//  SkyDictionary
//
//  Created by Никита Черников on 14/01/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import Foundation
import RxDataSources

enum PartOfSpeech: String {
    case noun = "n"
    case verb = "v"
    case adjective = "j"
    case adverb = "r"
    case preposition = "prp"
    case pronoun = "prn"
    case cardinalNumber = "crd"
    case conjunction = "cjc"
    case interjection = "exc"
    case article = "det"
    case abbreviation = "abb"
    case particle = "x"
    case ordinalNumber = "ord"
    case modalVerb = "md"
    case phrase = "ph"
    case idiom = "phi"
}

struct Meaning: Codable {
    
    let id: Int
    let partOfSpeechCode: String
    var partOfSpeech: PartOfSpeech? {
        get {
            return PartOfSpeech(rawValue: partOfSpeechCode)
        }
    }
    let translation: Translation?
    let previewUrl: String?
    let imageUrl: String?
    let transcription: String?
    let soundUrl: String?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case partOfSpeechCode
        case translation
        case previewUrl
        case imageUrl
        case transcription
        case soundUrl
    }
}

extension Meaning: IdentifiableType {
    var identity: Int {
        get {
            return id
        }
    }
}

extension Meaning: Equatable {
    static func == (lhs: Meaning, rhs: Meaning) -> Bool {
        return lhs.id == rhs.id
    }
}
