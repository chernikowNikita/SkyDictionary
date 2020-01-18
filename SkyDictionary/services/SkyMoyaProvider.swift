//
//  SkyMoyaProvider.swift
//  SkyDictionary
//
//  Created by Никита Черников on 18/01/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import Foundation
import Moya

class SkyMoyaProvider: MoyaProvider<SkyEngApiService> {
    static let shared = SkyMoyaProvider(plugins: [NetworkLoggerPlugin(verbose: true)])
}
