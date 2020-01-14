//
//  SearchVM.swift
//  SkyDictionary
//
//  Created by Никита Черников on 14/01/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import RxSwift
import RxCocoa
import Action
import Moya

let pageSize = 30

class SearchVM {
    
    // MARK: - Public properties
    let searchAction: Action<String, [SearchResult]> = {
        return Action<String, [SearchResult]>() { query in
            let provider = MoyaProvider<SkyEngApiService>()
            return provider.rx.request(.search(query: query, page: 1, pageSize: 30))
                .map([SearchResult].self)
                .catchErrorJustReturn([])
                .asObservable()
        }
    }()
    
    let searchResults: BehaviorSubject<[SearchResult]> = BehaviorSubject<[SearchResult]>(value: [])
    
    // MARK: - Private properties
    fileprivate let disposeBag = DisposeBag()
    
    // MARK: - Init
    init() {
        searchAction.elements.bind(to: searchResults)
            .disposed(by: disposeBag)
    }
}
