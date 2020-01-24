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
    case meaningDetails(meaningId: Int)
}

extension SkyEngApiService: TargetType {
    
    var baseURL: URL {
        return URL(string: "https://dictionary.skyeng.ru/api/public/v1")!
    }
    
    var path: String {
        switch self {
        case .search(query: _, page: _, pageSize: _):
            return "words/search"
        case .meaningDetails(meaningId: _):
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
        case .meaningDetails(meaningId: let id):
            return ["ids": id]
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    var sampleData: Data {
        switch self {
        case .search(_):
            return Data()
        case .meaningDetails(_):
            return stubbedResponse("meaning_details")
        }
    }
    
    var task: Task {
        if let params = parameters {
            return .requestParameters(parameters: params, encoding: URLEncoding())
        }
        return .requestPlain
    }
    
}

// MARK: - Mocks
extension SkyEngApiService {
    
    func stubbedResponse(_ filename: String) -> Data {
        if let url = Bundle.main.url(forResource: filename, withExtension: "json"),
            let data = try? Data(contentsOf: url) {
            return data
        }
        return Data()
    }
    
}
