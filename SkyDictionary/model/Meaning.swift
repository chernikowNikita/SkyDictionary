//
//  Meaning.swift
//  SkyDictionary
//
//  Created by Никита Черников on 14/01/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import Foundation

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
    private let partOfSpeechCode: String
    var partOfSpeech: PartOfSpeech? {
        get {
            return PartOfSpeech(rawValue: partOfSpeechCode)
        }
    }
    let translation: Translation
    let previewUrl: String
    let imageUrl: String
    let transcription: String
    let soundUrl: String
}
