//
//  FileWebService.swift
//  SkyDictionary
//
//  Created by Никита Черников on 19/01/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import Moya

enum FileWebService {
    case download(url: URL)
    
    var localLocation: URL {
        switch self {
        case .download(let url):
            return FileWebService.fileUrl(for: url)
        }
    }
    
    var downloadDestination: DownloadDestination {
        return { _, _ in return (self.localLocation, [.removePreviousFile, .createIntermediateDirectories]) }
    }
    
    static func fileUrl(for remoteUrl: URL) -> URL {
        let directory: URL = FileSystem.cacheDirectory
        return directory.appendingPathComponent(remoteUrl.absoluteString)
    }
    
}
extension FileWebService: TargetType {
    var baseURL: URL {
        switch self {
        case .download(let url):
            return url
        }
    }
    
    var path: String {
        switch self {
        case .download(_):
            return ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .download(_):
            return .get
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .download:
            return nil
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    var task: Task {
        switch self {
        case .download(_):
            return .downloadDestination(downloadDestination)
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var headers: [String: String]? {
        return nil
    }
    
}

class FileSystem {
    static let documentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.endIndex - 1]
    }()
    static let cacheDirectory: URL = {
        let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return urls[urls.endIndex - 1]
    }()
    static let downloadDirectory: URL = {
        let directory: URL = FileSystem.documentsDirectory.appendingPathComponent("/Download/")
        return directory
    }()
}
