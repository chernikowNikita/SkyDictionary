//
//  SearchResultsData.swift
//  SkyDictionary
//
//  Created by Никита Черников on 17/01/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import Foundation

class SearchResultsData {
    let isFirstPage: Bool
    let results: [SearchResult]
    
    init(isFirstPage: Bool, results: [SearchResult]) {
        self.isFirstPage = isFirstPage
        self.results = results
    }
}
