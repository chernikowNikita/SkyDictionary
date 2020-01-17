//
//  LoadingState.swift
//  SkyDictionary
//
//  Created by Никита Черников on 17/01/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import Foundation

enum LoadingState {
    case loading(firstPage: Bool)
    case notLoading
}
