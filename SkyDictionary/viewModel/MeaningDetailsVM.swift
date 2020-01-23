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
import RxDataSources

typealias ImageSection = SectionModel<String?, String>

class MeaningDetailsVM {
    
    // MARK: - Input
    let load: PublishSubject<Void> = PublishSubject<Void>()
    
    // MARK: - Output
    var loading: Observable<Bool> {
        return loadMeaningAction.enabled
            .map { !$0 }
            .share(replay: 1)
    }
    var loaded: Observable<Void> {
        return loadMeaningAction.elements
            .map { _ in () }
            .share(replay: 1)
    }
    var meaningLoaded: Observable<Void> {
        return meaning
            .map { _ in () }
            .share(replay: 1)
    }
    var error: Observable<Bool> {
        return loadMeaningAction.elements
            .map { $0 == nil }
            .share(replay: 1)
    }
    var text: Observable<String> {
        return meaning
            .map { $0.text }
            .share(replay: 1)
    }
    var transcription: Observable<String?> {
        return meaning
            .map { $0.transcription }
            .share(replay: 1)
    }
    var wordSoundUrl: Observable<URL?> {
        return meaning
            .map { $0.soundUrl }
            .map { link in
                if let s = link {
                    return URL(string: s)
                }
                return nil
            }
            .share(replay: 1)
    }
    var translation: Observable<String> {
        return meaning
            .map { meaning in
                var translation = meaning.translation?.text ?? ""
                if let note = meaning.translation?.note {
                    translation += " (\(note))"
                }
                return translation
            }
            .share(replay: 1)
    }
    var definition: Observable<String?> {
        return meaning
            .map { $0.definition?.text }
            .share(replay: 1)
    }
    var definitionSoundUrl: Observable<URL?> {
        return meaning
            .map { $0.definition?.soundUrl }
            .map { link in
                if let s = link {
                    return URL(string: s)
                }
                return nil
            }
            .share(replay: 1)
    }
    var difficultyLevel: Observable<Int?> {
        return meaning
            .map { $0.difficultyLevel }
            .share(replay: 1)
    }
    var images: Observable<[ImageSection]> {
        return meaning
            .map { meaning in
                return meaning.images.map { $0.url }
            }
            .map { ImageSection(model: nil, items: $0) }
            .map { [$0] }
            .share(replay: 1)
    }
    
    // MARK: - Private properties
    private let meaningId: Int
    private lazy var loadMeaningAction: Action<Int, MeaningDetails?> = {
        return Action<Int, MeaningDetails?>() { [weak self] meaningId in
            guard let strongSelf = self else { return Observable.just(nil) }
            return strongSelf.apiProvider.rx
                .request(.meaningDetails(meaningId: meaningId))
                .map([MeaningDetails].self)
                .catchErrorJustReturn([MeaningDetails]())
                .map { $0.first }
                .asObservable()
        }
    }()
    private var meaning: Observable<MeaningDetails> {
        return loadMeaningAction.elements
            .unwrap()
            .share(replay: 1)
    }
    private let loadedSound: PublishSubject<URL> = PublishSubject()
    private let apiProvider: MoyaProvider<SkyEngApiService>
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    init(meaningId: Int, apiProvider: MoyaProvider<SkyEngApiService>) {
        self.meaningId = meaningId
        self.apiProvider = apiProvider
        
        loadedSound
            .subscribe(onNext: { url in PlayerService.shared.play(url: url)})
            .disposed(by: disposeBag)
        
        load
            .map { [weak self] _ in return self?.meaningId }
            .unwrap()
            .bind(to: loadMeaningAction.inputs)
            .disposed(by: disposeBag)
    }
    
    func preparePlaySoundAction(for optUrl: URL?) -> CocoaAction? {
        guard let url = optUrl else { return nil }
        let service = LoadFileService(url: url, loadedFile: loadedSound)
        return service.action
    }
    
}
