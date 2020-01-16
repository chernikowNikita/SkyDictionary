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
import RxDataSources

let pageSize = 30

struct QueryData {
    let query: String
    let page: Int
    var isNeedToSearch: Bool {
        return query.count > 1
    }
}

class SearchResultsData {
    let isFirstPage: Bool
    let results: [SearchResult]
    
    init(isFirstPage: Bool, results: [SearchResult]) {
        self.isFirstPage = isFirstPage
        self.results = results
    }

}

typealias SearchResultSection = SectionModel<String, Meaning>

class SearchVM {
    
    // MARK: - Public properties
    // MARK: - Input
    let query: PublishSubject<String> = PublishSubject<String>()
    let page: BehaviorSubject<Int> = BehaviorSubject<Int>(value: 1)
    let nextPage: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    
    // MARK: - Output
    let searchResults: BehaviorSubject<[SearchResultSection]> = BehaviorSubject<[SearchResultSection]>(value: [])
    let provider = MoyaProvider<SkyEngApiService>(plugins: [NetworkLoggerPlugin(verbose: true)])
    
    // MARK: - Private properties
    fileprivate lazy var searchAction: Action<QueryData, SearchResultsData> = { this in
        return Action<QueryData, SearchResultsData>() { queryData in
            let query = queryData.query
            let page = queryData.page
            
            print("action initiated")
            
            let isFirstPage = page == 1
            return this.provider.rx
                .request(.search(query: query, page: page, pageSize: 30))
                .map([SearchResult].self)
                .catchErrorJustReturn([])
                .map { SearchResultsData(isFirstPage: isFirstPage, results: $0) }
                .asObservable()
        }
    }(self)
    fileprivate let disposeBag = DisposeBag()
    
    // MARK: - Init
    init() {
        searchAction.elements
            .scan([]) { array, newData -> [SearchResult] in
                if newData.isFirstPage {
                    return newData.results
                }
                return array + newData.results
            }
            
            .map { results -> [SearchResultSection] in
                return results.map { result in
                    return SearchResultSection(model: result.text, items: result.meanings)
                }
            }
            .bind(to: searchResults)
            .disposed(by: disposeBag)
        page
            .withLatestFrom(query) { page, query in
                return QueryData(query: query, page: page)
            }
            .filter { $0.isNeedToSearch }
            .debug()
            .bind(to: searchAction.inputs)
            .disposed(by: disposeBag)
        nextPage
            .withLatestFrom(page)
            .withLatestFrom(searchResults) { page, results -> Int? in
                return results.count / pageSize == page ? page : nil
            }
            .filter { $0 != nil }
            .map { $0! }
            .map { $0 + 1 }
            .debug()
            .bind(to: page)
            .disposed(by: disposeBag)
        query
            .map { _ in return 1 }
            .bind(to: page)
            .disposed(by: disposeBag)
        
    }
}
