//
//  MeaningDetailsVM.swift
//  SkyDictionary
//
//  Created by Никита Черников on 14/01/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import Foundation
import RxSwift
import Action
import Moya
import RxSwiftExt
import AVFoundation

typealias SoundUrlData = (word: URL?, meaning: URL?)

enum SoundType {
    case word
    case meaning
}

class MeaningDetailsVM {
    
    // MARK: - Input
    lazy var loadMeaningAction: Action<Void, MeaningDetails> = { this in
        return Action<Void, MeaningDetails>() { _ in
            return SkyMoyaProvider.shared.rx
                .request(.meaningDetails(meaningId: this.meaningId))
                .filterSuccessfulStatusCodes()
                .map([MeaningDetails].self)
                .debug()
                .catchErrorJustReturn([MeaningDetails.empty])
                .map { $0.first ?? .empty }
                .catchErrorJustReturn(MeaningDetails.empty)
                .debug()
                .asObservable()
        }
    }(self)
    
    // MARK: - Private properties
    private let meaningId: Int
    private let soundUrl: BehaviorSubject<SoundUrlData> = BehaviorSubject<SoundUrlData>(value: SoundUrlData(word: nil, meaning: nil))
    private let provider = MoyaProvider<SkyEngApiService>(plugins: [NetworkLoggerPlugin(verbose: true)])
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    init(meaningId: Int) {
        self.meaningId = meaningId
        
        loadMeaningAction.elements
            .map { meaning in
                var wordUrl: URL? = nil
                var meaningUrl: URL? = nil
                if let wordUrlString = meaning.soundUrl {
                    wordUrl = URL(string: wordUrlString.httpsPrefixed)
                }
                if let meaningUrlString = meaning.definition?.soundUrl {
                    meaningUrl = URL(string: meaningUrlString.httpsPrefixed)
                }
                return SoundUrlData(word: wordUrl, meaning: meaningUrl)
            }
            .bind(to: soundUrl)
            .disposed(by: disposeBag)
    }
    
    func play(type: SoundType) -> Observable<Void> {
        return Observable
            .just(type)
            .withLatestFrom(soundUrl) { type, data -> URL? in
                switch type {
                case .word:
                    return data.word
                case .meaning:
                    return data.meaning
                }
            }
            .unwrap()
            .flatMap { url -> Observable<URL?> in
                // Проверяем есть ли файл в кеше, если есть возвращаем его
                let localFileUrl = FileWebService.fileUrl(for: url)
                if FileManager.default.fileExists(atPath: localFileUrl.path) {
                    return Observable.just(localFileUrl)
                }
                // Загружаем с сервера, если в кеше нет файла
                return FileWebProvider.shared.rx
                    .request(.download(url: url))
                    .filterSuccessfulStatusCodes()
                    .map { _ in return localFileUrl }
                    .catchErrorJustReturn(nil)
                    .asObservable()
            }
            .do(onNext: { localSoundUrl in
                if let url = localSoundUrl {
                    PlayerService.shared.play(url: url)
                }
            })
            .map { _ in () }
        
    }
}
