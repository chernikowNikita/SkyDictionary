//
//  FileWebProvider.swift
//  SkyDictionary
//
//  Created by Никита Черников on 19/01/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import Foundation
import Moya

class FileWebProvider: MoyaProvider<FileWebService> {
    static let shared = FileWebProvider(plugins: [NetworkLoggerPlugin(verbose: true)])
}
