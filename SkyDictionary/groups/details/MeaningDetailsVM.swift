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
    let load: PublishSubject<Void> = PublishSubject<Void>()
    
    // MARK: - Output
    var loading: Observable<Bool> {
        return loadMeaningAction.enabled
            .map { !$0 }
    }
    var sharedLoaded: Observable<Void> {
        return loadMeaningAction.elements
            .map { _ in () }
            .share(replay: 1)
    }
    var sharedMeaning: Observable<MeaningDetails> {
        return loadMeaningAction.elements
            .unwrap()
            .share(replay: 1)
    }
    var sharedError: Observable<Bool> {
        return loadMeaningAction.elements
            .map { $0 == nil }
            .share(replay: 1)
    }
    var text: Observable<String> {
        return sharedMeaning
            .map { $0.text }
    }
    var transcription: Observable<String?> {
        return sharedMeaning
            .map { $0.transcription }
    }
    var translation: Observable<String> {
        return sharedMeaning
            .map { meaning in
                var translation = meaning.translation?.text ?? ""
                if let note = meaning.translation?.note {
                    translation += " (\(note))"
                }
                return translation
            }
    }
    var definition: Observable<String?> {
        return sharedMeaning
            .map { $0.definition?.text }
    }
    var difficultyLevel: Observable<Int?> {
        return sharedMeaning
            .map { $0.difficultyLevel }
    }
    var images: Observable<[ImageSection]> {
        return sharedMeaning
            .map { meaning in
                return meaning.images.map { $0.url }
            }
            .map { ImageSection(model: nil, items: $0) }
            .map { [$0] }
    }
    
    // MARK: - Private properties
    private let meaningId: Int
    private var loadMeaningAction: Action<Int, MeaningDetails?> = Action<Int, MeaningDetails?>() { meaningId in
        return SkyMoyaProvider.shared.rx
            .request(.meaningDetails(meaningId: meaningId))
            .map([MeaningDetails].self)
            .catchErrorJustReturn([MeaningDetails]())
            .map { $0.first }
            .asObservable()
    }
    private let soundUrl: BehaviorSubject<SoundUrlData> = BehaviorSubject<SoundUrlData>(value: SoundUrlData(word: nil, meaning: nil))
    private let provider = MoyaProvider<SkyEngApiService>(plugins: [NetworkLoggerPlugin(verbose: true)])
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    init(meaningId: Int) {
        self.meaningId = meaningId
        
        loadMeaningAction.elements
            .unwrap()
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
        
        load
            .map { [weak self] _ in return self?.meaningId }
            .unwrap()
            .bind(to: loadMeaningAction.inputs)
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
