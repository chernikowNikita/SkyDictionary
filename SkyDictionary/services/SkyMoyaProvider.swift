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
    private static let sharedProd = SkyMoyaProvider(plugins: [NetworkLoggerPlugin(verbose: true)])
    private static let sharedTest = SkyMoyaProvider(stubClosure: MoyaProvider.immediatelyStub)
    static var shared: SkyMoyaProvider {
        if isTest {
            return sharedTest
        }
        return sharedProd
    }
    static var isTest: Bool {
        return NSClassFromString("XCTest") != nil
    }
}
