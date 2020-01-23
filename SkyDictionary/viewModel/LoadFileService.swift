//
//  LoadFileService.swift
//  SkyDictionary
//
//  Created by Nikita Chernikov on 23/01/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Action

class LoadFileService {
    // MARK: - Public properties
    let action: CocoaAction
    
    // MARK: - Init
    init(url: URL, loadedFile: PublishSubject<URL>) {
        action = CocoaAction() { _ in
            return Observable.just(url)
                .flatMap { remoteUrl -> Observable<URL?> in
                    // Проверяем есть ли файл в кеше, если есть возвращаем его
                    let localUrl = FileWebService.fileUrl(for: remoteUrl)
                    if FileManager.default.fileExists(atPath: localUrl.path) {
                        return Observable.just(localUrl)
                    }
                    // Загружаем с сервера, если в кеше нет файла
                    return FileWebProvider.shared.rx
                        .request(.download(url: remoteUrl))
                        .map { _ in return localUrl }
                        .catchErrorJustReturn(nil)
                        .asObservable()
                }
                .do(onNext: { localUrl in
                    if let url = localUrl {
                        loadedFile.onNext(url)
                    }
                })
                .map { _ in ()}
            
        }
    }
}
