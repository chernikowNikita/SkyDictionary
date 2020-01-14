//
//  SceneTransitionType.swift
//  SkyDictionary
//
//  Created by Никита Черников on 14/01/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import Foundation

enum SceneTransitionType {
    case push
    case modal(inNavigationController: Bool)
}
