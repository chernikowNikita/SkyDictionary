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

class MeaningDetailsVM {
    
    // MARK: - Input
    lazy var loadMeaningAction: Action<Void, MeaningDetails> = { this in
        return Action<Void, MeaningDetails>() { _ in
            return SkyMoyaProvider.shared.rx
                .request(.meaningDetails(meaningId: this.meaningId))
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
    private let provider = MoyaProvider<SkyEngApiService>(plugins: [NetworkLoggerPlugin(verbose: true)])
    
    // MARK: - Init
    init(meaningId: Int) {
        self.meaningId = meaningId
    }
}
