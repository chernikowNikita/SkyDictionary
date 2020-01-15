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

struct QueryData {
    let query: String
    let page: Int
}

class SearchResultsData {
    let isFirstPage: Bool
    let results: [SearchResult]
    
    init(isFirstPage: Bool, results: [SearchResult]) {
        self.isFirstPage = isFirstPage
        self.results = results
    }
}

class SearchVM {
    
    // MARK: - Public properties
    // MARK: - Input
    let query: BehaviorSubject<String> = BehaviorSubject<String>(value: "")
    let page: BehaviorSubject<Int> = BehaviorSubject<Int>(value: 1)
    
    // MARK: - Output
    let searchResults: BehaviorSubject<[SearchResult]> = BehaviorSubject<[SearchResult]>(value: [])
    
    // MARK: - Private properties
    fileprivate let searchAction: Action<QueryData, SearchResultsData> = {
        return Action<QueryData, SearchResultsData>() { queryData in
            let query = queryData.query
            let page = queryData.page
            let provider = MoyaProvider<SkyEngApiService>()
            let isFirstPage = page == 1
            return provider.rx
                .request(.search(query: query, page: page, pageSize: 30))
                .map([SearchResult].self)
                .catchErrorJustReturn([])
                .map { SearchResultsData(isFirstPage: isFirstPage, results: $0) }
                .asObservable()
        }
    }()
    fileprivate let disposeBag = DisposeBag()
    
    // MARK: - Init
    init() {
        searchAction.elements
            .map { [weak self] newResultsData in
                var results: [SearchResult] = []
                if !newResultsData.isFirstPage {
                    results += (try? self?.searchResults.value()) ?? []
                }
                results += newResultsData.results
                return results
            }
            .bind(to: searchResults)
            .disposed(by: disposeBag)
        query
            .distinctUntilChanged()
            .map { _ in return 1 }
            .bind(to: page)
            .disposed(by: disposeBag)
        page
            .withLatestFrom(query) { page, query in
                return QueryData(query: query, page: page)
            }
            .bind(to: searchAction.inputs)
            .disposed(by: disposeBag)
    }
}
