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
    let play: PublishSubject<SoundType> = PublishSubject<SoundType>()
    
    // MARK: - Private properties
    private let soundUrl: BehaviorSubject<SoundUrlData> = BehaviorSubject<SoundUrlData>(value: SoundUrlData(word: nil, meaning: nil))
    private var player: AVAudioPlayer?
    private let meaningId: Int
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
        
        play
            .withLatestFrom(soundUrl) { type, data in
                switch type {
                case .word:
                    return data.word
                case .meaning:
                    return data.meaning
                }
            }
            .unwrap()
            .flatMap { url in
                FileWebProvider.shared.rx
                    .request(.download(url: url))
                    .filterSuccessfulStatusCodes()
                    .map { _ in return FileWebService.fileUrl(for: url) }
                    .catchErrorJustReturn(nil)
                    .debug()
                    .asObservable()
            }
            .unwrap()
            .subscribe(onNext: { url in
                PlayerService.shared.play(url: url)
            })
            .disposed(by: disposeBag)
    }
}
