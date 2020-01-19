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
import RxSwiftExt

typealias SearchResultSection = SectionModel<String, Meaning>

class SearchVM {
    
    // MARK: - Public properties
    // MARK: - Input
    let query: PublishSubject<String> = PublishSubject<String>()
    let page: BehaviorSubject<Int> = BehaviorSubject<Int>(value: 1)
    let nextPage: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    let retry: PublishSubject<Void> = PublishSubject<Void>()
    
    // MARK: - Output
    let searchResults: BehaviorSubject<[SearchResultSection]> = BehaviorSubject<[SearchResultSection]>(value: [])
    let loadingState: BehaviorSubject<LoadingState> = BehaviorSubject<LoadingState>(value: .notLoading)
    let error: BehaviorSubject<Bool> = BehaviorSubject<Bool>(value: false)
    
    // MARK: - Private properties
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    init() {
        let sharedSearch: Observable<QueryData> = page
            .withLatestFrom(query) { page, query in
                return QueryData(query: query, page: page)
            }
            .filter { $0.isNeedToSearch }
            .share(replay: 1)
        
        sharedSearch
            .map { data in
                return .loading(firstPage: data.isFirstPage )
            }
            .bind(to: loadingState)
            .disposed(by: disposeBag)
        
        sharedSearch
            .filter { $0.isFirstPage }
            .map { _ -> [SearchResultSection] in return [] }
            .bind(to: searchResults)
            .disposed(by: disposeBag)
        
        let sharedResults: Observable<SearchResultsData?> = sharedSearch
            .flatMapLatest { queryData -> Observable<SearchResultsData?> in
                return SkyMoyaProvider.shared.rx
                    .request(.search(query: queryData.query, page: queryData.page, pageSize: PAGE_SIZE))
                    .map([SearchResult].self)
                    .map { SearchResultsData(isFirstPage: queryData.isFirstPage, results: $0) }
                    .catchErrorJustReturn(nil)
                    .asObservable()
            }
            .share(replay: 1)
        
        sharedResults
            .map { _ in LoadingState.notLoading }
            .bind(to: loadingState)
            .disposed(by: disposeBag)
        
        sharedResults
            .unwrap()
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
        sharedResults
            .map { results in
                return results == nil
            }
            .bind(to: error)
            .disposed(by: disposeBag)
        
        nextPage
            .withLatestFrom(page)
            .withLatestFrom(searchResults) { page, results -> Int? in
                return results.count / PAGE_SIZE == page ? page : nil
            }
            .unwrap()
            .map { $0 + 1 }
            .debug()
            .bind(to: page)
            .disposed(by: disposeBag)
        
        retry
            .withLatestFrom(page)
            .bind(to: page)
            .disposed(by: disposeBag)
        
        query
            .map { _ in return 1 }
            .bind(to: page)
            .disposed(by: disposeBag)
        
    }
}
