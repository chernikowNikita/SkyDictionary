//
//  SkyEngApiService.swift
//  SkyDictionary
//
//  Created by Никита Черников on 14/01/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import Foundation
import Moya

enum SkyEngApiService {
    case search(query: String, page: Int, pageSize: Int)
    case meaningDetails(meaningIds: [Int])
}

extension SkyEngApiService: TargetType {
    
    var baseURL: URL {
        return URL(string: "https://dictionary.skyeng.ru/api/public/v1")!
    }
    var path: String {
        switch self {
        case .search(query: _, page: _, pageSize: _):
            return "words/search"
        case .meaningDetails(meaningIds: _):
            return "meanings"
        }
    }
    var method: Moya.Method {
        return .get
    }
    var headers: [String : String]? {
        return [:]
    }
    var parameters: [String: Any]? {
        switch self {
        case .search(query: let q, page: let page, pageSize: let pageSize):
            return [
                "search": q,
                "page": page,
                "pageSize": pageSize
            ]
        case .meaningDetails(meaningIds: let ids):
            return ["ids": ids.map { "\($0)" }.joined(separator: ",")]
        }
    }
    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    var sampleData: Data {
        return Data()
    }
    var task: Task {
        return .requestParameters(parameters: parameters!, encoding: URLEncoding())
    }
}
