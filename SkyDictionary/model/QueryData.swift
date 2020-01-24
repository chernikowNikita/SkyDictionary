//
//  QueryData.swift
//  SkyDictionary
//
//  Created by Никита Черников on 17/01/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import Foundation

struct QueryData {
    let query: String
    let page: Int
    
    var isNeedToSearch: Bool {
        return query.count > 1
    }
    var isFirstPage: Bool {
        return page == 1
    }
}
